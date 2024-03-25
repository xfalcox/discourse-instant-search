# frozen_string_literal: true

module ::InstantSearch
  class SearchesController < ::ApplicationController
    requires_plugin INSTANT_SEARCH

    def index
      render json: { hello: "world" }
    end
  end
end
