# frozen_string_literal: true

module Shipments
  module Constants
    # Dimensions par défaut des colis (en mm)
    DEFAULT_PARCEL_DIMENSIONS = {
      height: 50,
      width: 50,
      length: 50
    }.freeze

    # Configuration Postale
    POSTALE_CONFIG = {
      cust_acc_number: "671775",
      cust_invoice: "46",
      offer_code: "3125",
      product_code: "K7",
      client_reference: {
        cref1: "AK",
        cref2: "FX187VA"
      },
      master_output_options: {
        first_vignette_position: 1,
        visual_format_code: "rollA"
      }
    }.freeze

    # Pays supportés
    SUPPORTED_COUNTRIES = %w[FR].freeze

    # Transporteurs supportés
    SUPPORTED_CARRIERS = %w[mondial_relay colissimo chronopost colisprive sendcloud poste].freeze

    # Configuration des transporteurs
    CARRIER_CONFIG = {
      mondial_relay: { service_point_input: true, home_input: false },
      chronopost: { service_point_input: false, home_input: true },
      colissimo: { service_point_input: false, home_input: true },
      colisprive: { service_point_input: true, home_input: false },
      sendcloud: { service_point_input: false, home_input: false }
    }.freeze

    # Whitelist des transporteurs (à déplacer vers la config store)
    CARRIER_WHITELIST = {
      mondial_relay: { service_point_input: true, home_input: false },
      colissimo: { service_point_input: false, home_input: true }
    }.freeze

    # Statuts d'expédition
    SHIPPING_STATUSES = {
      processing: "processing",
      processed: "processed",
      failed: "failed"
    }.freeze

    # Types de contenu
    CONTENT_TYPES = {
      pdf: "application/pdf",
      png: "image/png"
    }.freeze

    # Extensions de fichiers
    FILE_EXTENSIONS = {
      pdf: ".pdf",
      png: ".png"
    }.freeze
  end
end
