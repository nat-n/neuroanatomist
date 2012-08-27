# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# seed the ontology with a root type
root_type = Type.new name: 'Thing', description: 'The root type of all things.'
root_type.supertype = root_type
root_type.save :validate => false

# seed an admin user

admin_user = User.create(:email => "admin@fake.com",
                         :password => "seeded_password")
admin_user.admin = true
admin_user.save