# frozen_string_literal: true

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:size]  = [1, 4, 4, 1]
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
