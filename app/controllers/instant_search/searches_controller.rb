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

      visible_categories = Category.all.filter { |category| guardian.can_see?(category) }

      typesense_categories =
        visible_categories
          .pluck(:id, :search_priority)
          .reduce({}) do |acc, (id, search_priority)|
            acc[search_priority] ||= []
            acc[search_priority] << id
            acc
          end
          .map do |k, v|
            k =
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

      typesense_category_eval = "_eval([ #{typesense_categories} ]):desc"

      categories_list =
        visible_categories.map do |category|
          {
            id: category.id,
            name: category.name,
            parent_category_id: category.parent_category_id,
            color: category.color,
          }
        end

      render json: {
               api_key: api_key,
               categories: typesense_category_eval,
               categories_list: categories_list,
             }
    end

    def embeddings
      params.require(%i[search_query hyde])

      search_query = params[:search_query]

      if search_query.blank?
        render json: { embeddings: [] }
        return
      end

      digest = OpenSSL::Digest::SHA1.hexdigest(search_query + params[:hyde].to_s)

      embeddings =
        Discourse
          .cache
          .fetch("instant-search-embeddings-#{digest}", expires_in: 1.second) do
            if params[:hyde]
              search_query =
                DiscourseAi::Embeddings::SemanticSearch.new(
                  Guardian.new(current_user),
                ).hypothetical_post_from(search_query)
            end

            strategy = DiscourseAi::Embeddings::Strategies::Truncation.new
            vector_rep =
              DiscourseAi::Embeddings::VectorRepresentations::Base.current_representation(strategy)

            vector_rep.vector_from(search_query)
          end

      render json: { embeddings: embeddings }
    end

    private

    def fetch_user_api_key(user)
      ::InstantSearch::Engines::Typesense.user_scoped_search_key(user)
    end
  end
end
