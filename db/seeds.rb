Booking.destroy_all
Venue.destroy_all
BookingContact.destroy_all
Gig.destroy_all

# Seeds pour une appli de booking de groupes/concerts

puts "🌍 Création des lieux (venues)..."
venues = [
  { name: "Le Supersonic", address: "9 Rue Biscornet", city: "Paris", state: "Île-de-France", zip_code: "75012", country: "France", phone: "+33 1 40 62 97 72", email: "contact@supersonic-club.fr", capacity: 300, language: "fr" },
  { name: "Le Point Ephémère", address: "200 Quai de Valmy", city: "Paris", state: "Île-de-France", zip_code: "75010", country: "France", phone: "+33 1 40 34 02 48", email: "booking@pointephemere.org", capacity: 400, language: "fr" },
  { name: "Le Rocher de Palmer", address: "1 Rue Aristide Briand", city: "Cenon", state: "Nouvelle-Aquitaine", zip_code: "33150", country: "France", phone: "+33 5 56 74 80 00", email: "contact@lerocherdepalmer.fr", capacity: 1200, language: "fr" },
  { name: "Le Bikini", address: "Rue Théodore Monod", city: "Ramonville-Saint-Agne", state: "Occitanie", zip_code: "31520", country: "France", phone: "+33 5 62 24 09 50", email: "info@lebikini.com", capacity: 1500, language: "fr" },
  { name: "Le Ferrailleur", address: "21 Quai des Antilles", city: "Nantes", state: "Pays de la Loire", zip_code: "44200", country: "France", phone: "+33 2 40 48 56 02", email: "contact@leferrailleur.fr", capacity: 350, language: "fr" }
]
venues.each { |attrs| Venue.find_or_create_by!(name: attrs[:name]) { |v| v.assign_attributes(attrs) } }
puts "✅ #{Venue.count} lieux créés"

puts "👤 Création des contacts (bookers/programmateurs)..."
contacts = [
  { name: "Alice Martin", email: "alice@supersonic.fr", phone: "+33 6 12 34 56 78", address: "9 Rue Biscornet", city: "Paris", state: "Île-de-France", zip_code: "75012", country: "France", notes: "Programmation rock, très réactive", language: "fr" },
  { name: "Benoît Dubois", email: "benoit@pointephemere.org", phone: "+33 6 98 76 54 32", address: "200 Quai de Valmy", city: "Paris", state: "Île-de-France", zip_code: "75010", country: "France", notes: "Aime les groupes émergents", language: "fr" },
  { name: "Claire Leroy", email: "claire@palmer.fr", phone: "+33 6 11 22 33 44", address: "1 Rue Aristide Briand", city: "Cenon", state: "Nouvelle-Aquitaine", zip_code: "33150", country: "France", notes: "Réponse parfois lente, préfère les mails", language: "fr" },
  { name: "David Morel", email: "david@lebikini.com", phone: "+33 6 55 66 77 88", address: "Rue Théodore Monod", city: "Ramonville-Saint-Agne", state: "Occitanie", zip_code: "31520", country: "France", notes: "Fan de pop, bon contact", language: "fr" },
  { name: "Emma Petit", email: "emma@leferrailleur.fr", phone: "+33 6 99 88 77 66", address: "21 Quai des Antilles", city: "Nantes", state: "Pays de la Loire", zip_code: "44200", country: "France", notes: "Programmation éclectique", language: "fr" }
]
contacts.each { |attrs| BookingContact.find_or_create_by!(email: attrs[:email]) { |c| c.assign_attributes(attrs) } }
puts "✅ #{BookingContact.count} contacts créés"

puts "📅 Création des bookings (demandes de concert)..."
bookings = [
  { gig: Gig.create!(date: Date.current + 1.month, time: Time.current.change(hour: 20, min: 0), duration: "2 hours", price: 300, description: "Soirée Indie Rock"), booking_contact: BookingContact.find_by(name: "Alice Martin"), notes: "Premier contact par mail, attente de réponse" },
  { gig: Gig.create!(date: Date.current + 2.months, time: Time.current.change(hour: 19, min: 30), duration: "1h30", price: 500, description: "Release Party"), booking_contact: BookingContact.find_by(name: "Benoît Dubois"), notes: "Contrat signé, loge prévue" },
  { gig: Gig.create!(date: Date.current + 3.months, time: Time.current.change(hour: 21, min: 0), duration: "1h", price: 800, description: "Première partie d'un gros groupe"), booking_contact: BookingContact.find_by(name: "Claire Leroy"), notes: "En attente de validation du groupe principal" },
  { gig: Gig.create!(date: Date.current + 1.week, time: Time.current.change(hour: 20, min: 30), duration: "2h", price: 1000, description: "Tournée d'été"), booking_contact: BookingContact.find_by(name: "David Morel"), notes: "Annulé par la salle (travaux)" },
  { gig: Gig.create!(date: Date.current + 2.weeks, time: Time.current.change(hour: 19, min: 0), duration: "1h30", price: 400, description: "Carte blanche à un label"), booking_contact: BookingContact.find_by(name: "Emma Petit"), notes: "Backline fourni, hébergement à prévoir" }
]
bookings.each do |attrs|
  booking = Booking.create!(gig: attrs[:gig], booking_contact: attrs[:booking_contact], notes: attrs[:notes])

  # Créer des étapes de booking selon le contexte
  case attrs[:booking_contact].name
  when "Alice Martin"
    BookingStep.create!(booking: booking, step_type: "premier_contact", comment: "Email envoyé à Alice", created_at: attrs[:gig].date - 10.days)
  when "Benoît Dubois"
    BookingStep.create!(booking: booking, step_type: "premier_contact", comment: "Appel téléphonique", created_at: attrs[:gig].date - 15.days)
    BookingStep.create!(booking: booking, step_type: "booke", comment: "Contrat signé", created_at: attrs[:gig].date - 10.days)
  when "Claire Leroy"
    BookingStep.create!(booking: booking, step_type: "premier_contact", comment: "Mail de présentation", created_at: attrs[:gig].date - 20.days)
    BookingStep.create!(booking: booking, step_type: "relance", comment: "Relance par téléphone", created_at: attrs[:gig].date - 10.days)
  when "David Morel"
    BookingStep.create!(booking: booking, step_type: "premier_contact", comment: "Contact initial", created_at: attrs[:gig].date - 7.days)
    BookingStep.create!(booking: booking, step_type: "indisponible", comment: "Salle en travaux", created_at: attrs[:gig].date - 3.days)
  when "Emma Petit"
    BookingStep.create!(booking: booking, step_type: "premier_contact", comment: "Email de demande", created_at: attrs[:gig].date - 12.days)
    BookingStep.create!(booking: booking, step_type: "booke", comment: "Validation rapide", created_at: attrs[:gig].date - 10.days)
  end
end
puts "✅ #{Booking.count} bookings créés"

puts "🎉 Seeds terminés !"
puts "📊 Résumé :"
puts "   - #{Venue.count} lieux"
puts "   - #{BookingContact.count} contacts"
puts "   - #{Booking.count} bookings"
puts ""
puts "🌐 Tu peux maintenant tester le workflow complet sur l'admin."
