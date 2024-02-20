# frozen_string_literal: true

module Filterable
  class View < ApplicationRecord
    self.table_name = 'filterable_views'

    belongs_to :owner, polymorphic: true

    validates :title, :model, :conjonction, :context_name, presence: true
    validates :conjonction, inclusion: { in: %w[and or] }

    scope :for_context, lambda { |context|
      where(
        model: context.model.name,
        owner_type: context.views_owner.model_name.name,
        owner_id: context.views_owner.id,
        context_name: context.name
      )
    }

    def to_path(submit_path)
      uri = URI.parse(submit_path)
      uri.query = {
        filterable: { filters:, conjonction:, sort:, selected_view_id: id }
      }.to_query
      uri.to_s
    end

    def query=(value)
      return if value.blank?

      value.with_defaults!(conjonction: 'and', sort: {}, filters: [])

      assign_attributes(value.slice(:conjonction, :sort, :filters))
    end
  end
end
