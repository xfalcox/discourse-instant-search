# frozen_string_literal: true

task "instant_search:prepare" => [:environment] do
  InstantSearch::Collections::User.create_collection
  InstantSearch::Collections::Topic.create_collection
  InstantSearch::Collections::Post.create_collection
  InstantSearch::Collections::ChatMessage.create_collection
end

task "instant_search:destroy" => [:environment] do
  InstantSearch::Collections::User.destroy_collection
  InstantSearch::Collections::Topic.destroy_collection
  InstantSearch::Collections::Post.destroy_collection
  InstantSearch::Collections::ChatMessage.destroy_collection
end

task "instant_search:index" => [:environment] do
  User.find_in_batches do |batch|
    batch.each { |user| Jobs.enqueue(:index, id: user.id, type: "User") }
  end

  Topic.find_in_batches do |batch|
    batch.each { |topic| Jobs.enqueue(:index, id: topic.id, type: "Topic") }
  end

  Chat::Message.find_in_batches do |batch|
    batch.each { |chat_message| Jobs.enqueue(:index, id: chat_message.id, type: "Chat::Message") }
  end

  Post.find_in_batches do |batch|
    batch.each { |post| Jobs.enqueue(:index, id: post.id, type: "Post") }
  end
end
