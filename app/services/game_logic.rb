class GameLogic
  attr_accessor :user, :user_marker, :markers

  def initialize(user, user_marker, markers=[])
    self.user = user
    self.user_marker = user_marker
    self.markers = markers
  end

  def message
    full_markers = self.markers + [self.user_marker]

    @markers_neighbors = full_markers.map { |marker|
      markers_distances = full_markers.map { |comp_marker|
        a = marker.lng - comp_marker.lng
        b = marker.lat - comp_marker.lat
        distance = (a.power(2) + b.power(2)).sqrt(1).to_f
        { marker: comp_marker, distance: distance }
      }
      sorted = markers_distances.sort { |x,y| x[:distance] <=> y[:distance] }
      neighbor = sorted[1][:marker]
      { marker: marker, neighbor: neighbor }
    }
    if !self.user_marker.zombie
      message = self.human_logic(@markers_neighbors, self.user_marker, self.user)
    else
      message = zombie_logic(@markers_neighbors, self.user_marker, self.user)
    end

    message
  end

  def human_logic(markers_neighbors, user_marker, user)
    user_marker_neighbor = markers_neighbors.find { |marker_neighbor|
      marker_neighbor[:marker] == user_marker
    }

    if user_marker_neighbor[:neighbor][:zombie]
      user.zombie = true
      message = {
        status: "hl",
        neighbor: user_marker_neighbor[:neighbor].user.username,
        infected: []
      }
    else
      if user.updated_at < Time.zone.today
        user.days_survived += 1
      end
      message = {
        status: "hw",
        neighbor: user_marker_neighbor[:neighbor].user.username,
        infected: []
      }
    end

    user.save
    message
  end

  def zombie_logic(markers_neighbors, user_marker, user)
    infected_markers_neighbors = markers_neighbors.select { |marker_neighbor|
      marker_is_human = !marker_neighbor[:marker][:zombie]
      neighbor_is_user = marker_neighbor[:neighbor] == user_marker

      marker_is_human && neighbor_is_user
    }

    if infected_markers_neighbors.length == 0
      message = {
        status: "zl",
        neighbor: "",
        infected: []
      }
    else
      if user.updated_at < Time.zone.today
        user.humans_infected += infected_markers_neighbors.length
      end
      message = {
        status: "zw",
        neighbor: "",
        infected: infected_markers_neighbors.map { |marker_neighbor| marker_neighbor[:marker].user.username }
      }
    end

    user.save
    message
  end

  def loner_logic(user, user_marker)
    if user_marker[:zombie]
      message = {
        status: "zl",
        neighbor: "",
        infected: []
      }
    else
      if user.updated_at < Time.zone.today
        user.days_survived += 1
      end
      message = {
        status: "hd",
        neighbor: "",
        infected: []
      }
    end

    message
  end
end
