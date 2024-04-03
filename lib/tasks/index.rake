# frozen_string_literal: true

task "instant_search:prepare" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.create_collection }
end

task "instant_search:destroy" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.destroy_collection }
end

task "instant_search:index" => [:environment] do
  InstantSearch::Collections::Base.subclasses.each do |collection|
    collection.model.find_in_batches do |batch|
      batch.each do |object|
        Jobs.enqueue(:index, id: object.id, action: "upsert", type: collection.class_name)
      end
    end
  end
end
