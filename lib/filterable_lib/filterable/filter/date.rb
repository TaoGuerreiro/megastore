# frozen_string_literal: true

module Filterable
  class Filter
    class Date < Filter
      INPUT_LESS_OPERATORS = (Filter::INPUT_LESS_OPERATORS + ['lteq_end_of_month']).freeze

      operator('equal') do
        if datetime_column?
          all_day = cast_value
          arel_column.gteq(all_day.begin).and(arel_column.lteq(all_day.end))
        else
          arel_column.eq(cast_value)
        end
      end

      operator('not_equal') do
        if datetime_column?
          all_day = cast_value
          arel_column.lt(all_day.begin).or(arel_column.gt(all_day.end))
        else
          arel_column.not_eq(cast_value)
        end
      end

      operator('gt') { arel_column.gt(cast_value) }
      operator('gteq') { arel_column.gteq(cast_value) }
      operator('lt') { arel_column.lt(cast_value) }
      operator('lteq') { arel_column.lteq(cast_value) }
      operator('empty') { arel_column.eq(nil) }
      operator('not_empty') { arel_column.not_eq(nil) }
      operator('lteq_end_of_month') { arel_column.lteq(end_of_current_month) }

      private

      def cast_value
        value = value_for_sql
        cast_value = value.iso8601 unless value.is_a?(::String)
        datetime = Time.zone.parse(cast_value || value)

        column.type == :date ? datetime.to_date : adjust_datetime_value(datetime)
      end

      ##
      # When column is of type `datetime`, value must be adjusted so it returns correct results
      # when filtering with a whole date, without time
      def adjust_datetime_value(datetime)
        case operator
        when 'gt', 'lteq' then datetime.end_of_day
        when 'lt', 'gteq' then datetime.beginning_of_day
        when 'equal', 'not_equal' then datetime.all_day
        else
          datetime
        end
      end

      def datetime_column?
        column.type == :datetime
      end

      def end_of_current_month
        Time.current.end_of_month
      end
    end
  end
end
