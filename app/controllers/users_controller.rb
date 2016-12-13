class UsersController < ApplicationController

  def create
    user = User.new(user_params)

    if rand(1..6) == 6
      user.zombie = true
    else
      user.zombie = false
    end

    if user.save
      jwt = Auth.issue({user_id: user.id})
      render json: {
        jwt: jwt,
        previous_marker: false
      }
    else
      render json: {
        error: user.errors.full_messages.first
      }
    end
  end

  def index
    user_id = Auth.decode(params["jwt"])["user_id"]
    if user_id
      marker = Marker.find_by("user_id = ? AND created_at >= ?", user_id, Time.zone.now.beginning_of_day)
      user = User.find(user_id)
      if marker
        render json: {
          user: {
            zombie: user.zombie
          },
          marker: {
            position: {lat: marker.lat, lng: marker.lng}
          }
        }
      else
        render json: {
          user: {
            zombie: user.zombie
          },
          marker: {
            position: {lat: 0, lng: 0}
          }
        }
      end
    else
      render json: {
        error: "some sort of jwt error"
      }
    end
  end

  private
  def user_params
    params.require(:auth).permit(:username, :password)
  end
end
