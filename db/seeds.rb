# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Store.destroy_all
User.destroy_all

admin_localhost = User.create(first_name: "Ted", last_name: "Lasso", email: "admin@example.fr", password: "123456", role: "admin")


admin_localhost.stores.create(domain: "localhost", name: "Le Cheveu Blanc", slug: "lecheveublanc")
admin_localhost.stores.create(domain: "ngrok.io", name: "Gros Rock", slug: "grosrock")
