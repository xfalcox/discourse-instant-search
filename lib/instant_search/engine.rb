# frozen_string_literal: true

module ::InstantSearch
  class Engine < ::Rails::Engine
    engine_name INSTANT_SEARCH
    isolate_namespace InstantSearch
    config.autoload_paths << File.join(config.root, "lib")
    config.eager_load_paths << File.join(config.root, "lib")
    config.rake_eager_load = true
    config.eager_load = false
  end
end
