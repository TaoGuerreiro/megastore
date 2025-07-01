class BookingStep < ApplicationRecord
  belongs_to :booking

  enum step_type: {
    premier_contact: "premier_contact",
    relance: "relance",
    nrp: "nrp",
    indisponible: "indisponible",
    booke: "booke",
    incompatible: "incompatible",
    erreur_envoi_mail: "erreur_envoi_mail"
  }

  validates :step_type, presence: true
end
