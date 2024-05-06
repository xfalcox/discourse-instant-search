# frozen_string_literal: true

module ::InstantSearch
  class SearchesController < ::ApplicationController
    requires_plugin INSTANT_SEARCH

    def index
      render json: {}
    end

    def api_key
      api_key = fetch_user_api_key(current_user)
      guardian = Guardian.new(current_user)
      categories =
        Category
          .all
          .filter { |category| guardian.can_see?(category) }
          .pluck(:id, :search_priority)
          .reduce({}) do |acc, (id, search_priority)|
            acc[search_priority] ||= []
            acc[search_priority] << id
            acc
          end
          .map do |k, v|
            k = # refit the enum into something bearable
              case k
              when 2
                1
              when 3
                2
              when 0
                3
              when 4
                4
              when 5
                5
              else
                0
              end
            { k => v }
          end
          .sort_by { |cats| cats.keys.first }
          .map { |cats| "(category_id: [#{cats.values.join(", ")}]):#{cats.keys.first}" }
          .join(", ")

      typesense_category_eval = "_eval([ #{categories} ]):desc"

      render json: { api_key: api_key, categories: typesense_category_eval }
    end

    private

    def fetch_user_api_key(user)
      ::InstantSearch::Engines::Typesense.user_scoped_search_key(user)
    end
  end
end
