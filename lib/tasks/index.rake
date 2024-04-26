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
    queue = SizedQueue.new(20)
    Thread.new do
      collection.model.find_in_batches { |batch| batch.each { |object| queue.push object } }
      queue.push Parallel::Stop
    end

    Parallel.each(-> { queue.pop }, in_processes: args[:concurrency].to_i) do |item|
      ActiveRecord::Base.connection_pool.with_connection do
        collection.new(item).create
        i += 1
        print "### Indexed #{i * 100 * args[:concurrency].to_i / total}% of #{collection.name}          \r"
      end
    end
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
