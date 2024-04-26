import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import loadInstantSearch from "discourse/lib/load-instant-search";

export default class InstantSearch extends Controller {
  @service siteSettings;
  @tracked instantSearchModule;
  @tracked searchType = "topics";
  @tracked query = "";
  @tracked apiKey = this.model.api_key;

  constructor() {
    super(...arguments);
    this.loadInstantSearch();
  }

  get customMiddleware() {
    const context = this;
    return [
      () => ({
        onStateChange({ uiState }) {
          const { topics } = uiState;
          const { sortBy } = topics;

          if (topics?.query) {
            context.query = topics.query;
          }

          switch (sortBy) {
            case "posts":
              context.searchType = "posts";
              break;
            case "topics":
              context.searchType = "topics";
              break;
            case "chat_messages":
              context.searchType = "chat_messages";
              break;
            case "users":
              context.searchType = "users";
              break;
            default:
              context.searchType = "topics";
          }
        },
        subscribe() {},
        unsubscribe() {},
      }),
    ];
  }

  get apiData() {
    let indexes = {
      posts: {
        query_by: "topic_title,raw",
        query_by_weights: "2,1",
        exclude_fields: "embeddings",
        facet_by: "author_username,category,tags",
      },
      topics: {
        query_by: "title,blurb",
        exclude_fields: "embeddings",
        facet_by: "author_username,category",
      },
      users: {
        query_by: "username,name",
        facet_by: "groups",
      },
      chat_messages: {
        query_by: "raw",
        facet_by: "author_username,channel_name",
      },
    };
    const typesenseNodes = JSON.parse(this.siteSettings.typesense_nodes);

    return {
      apiKey: this.apiKey,
      port: typesenseNodes[0].port,
      host: typesenseNodes[0].host,
      protocol: typesenseNodes[0].protocol,
      indexName: this.searchType,
      queryBy: indexes[this.searchType].query_by,
    };
  }

  get searchParameters() {
    return {
      posts: {
        query_by: "topic_title,raw",
        query_by_weights: "2,1",
        exclude_fields: "embeddings",
        facet_by: "author_username,category,tags",
      },
      topics: {
        query_by: "title,blurb",
        exclude_fields: "embeddings",
        facet_by: "author_username,category",
      },
      users: {
        query_by: "username,name",
        facet_by: "groups",
      },
      chat_messages: {
        query_by: "cooked",
        facet_by: "author_username,channel_name",
      },
    };
  }

  async loadInstantSearch() {
    this.instantSearchModule = await loadInstantSearch();
  }

  get instantSearch() {
    return this.instantSearchModule;
  }
}
