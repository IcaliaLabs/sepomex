# frozen_string_literal: true

# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.production? && ENV['DEPLOY_NAME'] == 'production'
  Municipality.count.zero? && (bundle exec rake 'data:load')
end
