# frozen_string_literal: true

task "instant_search:prepare" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.create_collection }
end

task "instant_search:destroy" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.destroy_collection }
end

task "instant_search:index" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each do |collection|
    puts "### Indexing #{collection.class_name}"
    i = 0
    total = collection.model.count
    collection.model.find_in_batches do |batch|
      batch.each do |object|
        Jobs.enqueue(:index, id: object.id, action: "upsert", type: collection.class_name)
      end
      puts "### Indexed #{i = i + batch.size} of #{collection.class_name} (#{i * 100 / total}%)"
    end
  end
end

task "instant_search:eager_load" => [:environment] do
  #Zeitwerk::Loader.eager_load_all

  # TODO This is a hack to force eager loading of all classes
  # We should find a better way to do this
  # see unresolved https://github.com/rails/rails/issues/37006
  require "instant_search/collections/base"
  require "instant_search/collections/topic"
  require "instant_search/collections/post"
  require "instant_search/collections/user"
  require "instant_search/collections/chat_message"
end

task "instant_search:prepare" => "instant_search:eager_load"
task "instant_search:destroy" => "instant_search:eager_load"
task "instant_search:index" => "instant_search:eager_load"
