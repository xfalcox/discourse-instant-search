# frozen_string_literal: true

InstantSearch::Engine.routes.draw do
  get "/" => "searches#index"
  get "/key" => "searches#api_key"
  post "/embeddings" => "searches#embeddings"
end

Discourse::Application.routes.draw { mount ::InstantSearch::Engine, at: "instant-search" }
