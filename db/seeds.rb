# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

names = [
  'Bobby',
  'Hank',
  'Peggy',
  'Luanne',
  'Ladybird',
  'Dale',
  'Nancy',
  'Joseph',
  'Bill',
  'Boomhauer',
  'Bart',
  'Lisa',
  'Homer',
  'Marge',
  'Maggie',
  'Moe',
  'Barney',
  'Sideshow Bob',
  'Krusty',
  'Chief Wiggum'
]

n_lat = 40.708
s_lat = 40.702
e_lng = -74.010
w_lng = -74.018

names.each { |name|
  user = User.new(username: name, password: name)
  if rand(1..6) == 6
    user.zombie = true
    user.humans_infected = rand(1..25)
  else
    user.zombie = false
    user.days_survived = rand(1..10)
  end

  user.created_at = 1.days.ago
  user.updated_at = 1.days.ago
  user.save

  lat = rand(s_lat..n_lat)
  lng = rand(w_lng..e_lng)

  marker = Marker.new(user_id: user.id, lat: lat, lng: lng)
  marker.zombie = marker.user.zombie
  marker.created_at = 1.days.ago
  marker.updated_at = 1.days.ago
  marker.save
}
