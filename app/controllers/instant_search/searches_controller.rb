# frozen_string_literal: true

module ::InstantSearch
  class SearchesController < ::ApplicationController
    requires_plugin INSTANT_SEARCH

    def index
      api_key = fetch_user_api_key(current_user)

      render json: { api_key: api_key }
    end

    private

    def fetch_user_api_key(user)
      ::InstantSearch::Engines::Typesense.user_scoped_search_key(user)
    end
  end
end
