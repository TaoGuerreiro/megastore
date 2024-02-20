# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :floating_label, tag: 'div', class: 'form-group relative', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :input, class: 'form-input'
    b.use :label, class: 'floating-label'
    b.use :error, wrap_with: { tag: 'span', class: 'error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint' }
  end

  config.default_wrapper = :floating_label
  config.boolean_style = :nested
  config.button_class = 'btn btn-primary'
  config.error_notification_tag = :div
  config.error_notification_class = 'error_notification'
  config.label_class = 'control-label'
  config.generate_additional_classes_for = ['field']

  config.required_by_default = false
  config.label_text = ->(label, _required, _explicit_label) { label.to_s }

  config.browser_validations = false
end
