# frozen_string_literal: true

task "instant_search:prepare" => [:environment] do
  load!
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.create_collection }
end

task "instant_search:destroy" => [:environment] do
  load!
  InstantSearch::Collections::Base.subclasses.each { |collection| collection.destroy_collection }
end

task "instant_search:index", %i[concurrency] => [:environment] do |_, args|
  load!
  InstantSearch::Collections::Base.subclasses.each do |collection|
    puts "### Indexing #{collection.name}"
    i = 0
    total = collection.model.count
    queue = SizedQueue.new(50)
    concurrency = args[:concurrency].to_i
    end_object = Object.new
    client = InstantSearch::Engines::Typesense.client
    lowest_hits =
      client.collections[collection.collection].documents.search(
        { q: "*", sort_by: "created_at:asc" },
      )
    lowest_id = lowest_hits.dig("hits", 0, "document", "id")

    Thread.new do
      col = collection.model
      col = col.where("id < ?", lowest_id) if lowest_id.present?
      col.find_in_batches(order: :desc) { |batch| batch.each { |object| queue.push object } }
      concurrency.times { queue.push end_object }
    end

    consumers =
      concurrency.times.map do
        Thread.new do
          until (item = queue.pop) == end_object
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                collection.new(item).create
              rescue StandardError => e
                puts "### Error indexing #{item.class.name} #{item.id}: #{e.message}"
              end
              i += 1
              print "### Indexed #{i * 100 / total}% of #{collection.name}          \r"
            end
          end
        end
      end

    consumers.each(&:join)

    puts "### Indexed #{collection.name} done                      "
  end
end

def load!
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
