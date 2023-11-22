# [LIB] Dynamic Filters

_⚠️ Requires **Hotwire**, **TailwindCSS** and **FontAwesome**_

## Installation

Start by copying whole `filterable_lib` folder to `/lib`

Then copy each of these files/folders to their respective directory:

`app/javascript/controllers/filterable_controller.js`

`app/javascript/controllers/filterable_sort_controller.js`

`app/controllers/filterable/filters_controller.rb`

1.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Filterable::FilterableRequest
  # [...]
end
```a

2.

```ruby
# app/helpers/application_helper.rb

module ApplicationHelper
  include Filterable::FilterableHelper
  # [...]
end
```

3.

```ruby
# config/application.rb
# [...]
module MyApp
  class Application < Rails::Application
    # [...]
    config.autoload_paths += Dir[Rails.root.join("lib/filterable_lib")]
    config.i18n.load_path += Dir[Rails.root.join("lib/filterable_lib/locales/**/*.yml")]
  end
end
```

4.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # [...]
  resources :filterables, only: [], param: :model_name do
    resource :filters, only: %i[show create], controller: "filterable/filters"
  end
end
```

5.

```js
# config/tailwind.config.js
const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    // [...]
    "./lib/filterable_lib/**/*.rb",
  ]
  theme: {
    extend: {
      colors: {
        primary: colors.indigo, // You need to have set a primary color
        // [...]
      }
  // [...]
}
```

## Usage

First you need to configure the model:

```ruby
class Order
  include Filterable # Add this line

  has_one :chief # ...

  # AFTER ASSOCIATIONS:
  filterable do
    # add several filterable columns at once
    columns :supplier, :state

    # add one filterable column to specify formatter
    # formatter is called before passing user input to filter
    column :total_amount_cents, input_formatter: proc { |value| Money.from_amount(value).cents }

    # the label_method is used for display in the select list
    association :chief, label_method: :full_name

    # a scope can be passed to be used for the select list
    association :chief, label_method: :full_name, select_scope: -> { where(feathured: true) }
    # can be either lambda or symbol
    association :chief, label_method: :full_name, select_scope: :feathered_chiefs

    # if you want to filter on the column from an association
    # (N.B: you can also provide an input_formatter)
    associated_column :code, from: :project
  end
end
```

Next, in the view, where you want to display the filters:

```ruby
<%= filterable_form_for(Project) %>
```

Finally, in the controller:

```ruby
# NB: if they are no submitted filters, this simply returns `Project.all`
@projects = filterable(Project)

# you can also pass a base relation like this:
@projects = fitlerable(Project, current_user.projects)

# you can then chain this with other query methods:
@projects = @projects.
    includes(users: { avatar_attachment: :blob }).
    includes(:assignments).
    includes(reviews: [:rich_text_current_state, :rich_text_next_step, :risks]).
    order("reviews.created_at DESC").
    with_attached_logo
```

### Sorting

if you want to sort (any) column of the model, you don’t need to add anything in the configuration. All you have to do is to use the `filterable_sort` helper.

Example from a html table:

```ruby
th.whitespace-normal.md:whitespace-nowrap.lg:sticky.left-0.z-0 scope="col"
  .bg-gray-50.border-r
    = filterable_sort_button(Project, :name) do
      # this can also contains html
      - t(".project_name")
```

_⚠️ Only one sort can be active at a time_

_⚠️ Note that the sorting will always take filters into account_


### Customization

Not much but the wrapper button stype

You can change the button’s classes in the `Filterable` module

```ruby
module Filterable
  def self.btn_classes
    "btn btn-secondary"
  end

  def self.btn_active_classes
    "bg-neutral-100 font-semibold"
  end
end
```
