class MarkersController < ApplicationController

  def index
    user_id = Auth.decode(params["jwt"])["user_id"]
    if user_id
      user = User.find(user_id)
      user_marker = last_user_marker(user_id)
      if user_marker
        markers = nearby_markers(user_marker, user_id)
        if markers.length != 0
          message = GameLogic.new(user, user_marker, markers).message
        else
          message = GameLogic.new(user, user_marker).loner_logic
        end
      else
        markers = nil
      end

      if markers
        results = markers.each_with_object([]) do |marker, array|
          array << {
            position: {
              lat: marker.lat,
              lng: marker.lng
            },
            zombie: marker.zombie,
            username: marker.user.username
          }
        end

        render json: {
          message: message,
          markers: {
            user: {
              position: {
                lat: user_marker.lat,
                lng: user_marker.lng
              },
              zombie: user_marker.zombie
            },
            nearby: results,
            date: user_marker.created_at.strftime("%B%e, %Y - %A")
          }
        }
      else
        render json: {
          error: "no markers"
        }
      end
    else
      render json: {
        error: "some sort of jwt error"
      }
    end
  end

  def create
    user_id = Auth.decode(params["jwt"])["user_id"]
    if user_id
      marker = Marker.find_by("user_id = ? AND created_at >= ?", user_id, Time.zone.now.beginning_of_day)
      if marker
        update_marker(marker, params)
      else
        create_marker(user_id, params)
      end
    else
      render json: {
        error: "some sort of jwt error"
      }
    end
  end

  private

  def create_marker(user_id, params)
    marker = Marker.new(user_id: user_id, lat: params["data"]["lat"], lng: params["data"]["lng"])
    marker.zombie = marker.user.zombie
    marker.save

    render json: {
      status: "created"
    }
  end

  def update_marker(marker, params)
    marker.update(lat: params["data"]["lat"], lng: params["data"]["lng"])
    render json: {
      status: "updated"
    }
  end

  def last_user_marker(user_id)
    Marker.where("user_id = ? AND created_at < ?", user_id, Time.zone.now.beginning_of_day).order("created_at ASC").last
  end

  def nearby_markers(user_marker, user_id)
    lat_min = user_marker.lat - 0.004
    lat_max = user_marker.lat + 0.004
    lng_min = user_marker.lng - 0.004
    lng_max = user_marker.lng + 0.004

    Marker.where("created_at >= ? AND created_at <= ? AND (lat BETWEEN ? AND ?) AND (lng BETWEEN ? AND ?) AND user_id != ?",
     user_marker.created_at.beginning_of_day, user_marker.created_at.end_of_day, lat_min, lat_max, lng_min, lng_max, user_id)
  end
end
