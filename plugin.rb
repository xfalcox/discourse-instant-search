# frozen_string_literal: true

# name: discourse-instant-search
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 3.2.0

gem "ethon", "0.14.0"
gem "typhoeus", "1.4.0"
gem "typesense", "1.0.0"

enabled_site_setting :instant_search_enabled

module ::InstantSearch
  INSTANT_SEARCH = "discourse-instant-search"
end

require_relative "lib/instant_search/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
