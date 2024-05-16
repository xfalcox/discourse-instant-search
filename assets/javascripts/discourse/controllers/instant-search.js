import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class InstantSearch extends Controller {
  @service dInstantSearch;
  @tracked categoryWeights = this.model.categories;
  @tracked searchMode = "keyword";
  @tracked
  searchParameters = {
    posts: {
      query_by: "raw,topic_title",
      query_by_weights: "3,1",
      exclude_fields: "embeddings",
      facet_by:
        "author_username,category,tags,type,allowed_users,allowed_groups",
      sort_by: `_text_match(buckets: 20):desc,${this.categoryWeights}`,
    },
    topics: {
      query_by: "title,blurb",
      exclude_fields: "embeddings",
      facet_by:
        "author_username,category,tags,type,allowed_users,allowed_groups",
      sort_by: `_text_match(buckets: 10):desc,${this.categoryWeights}`,
    },
    users: {
      query_by: "username,name",
      facet_by: "trust_level,groups",
      sort_by: "_text_match:desc,trust_level:desc,likes_received:desc",
    },
    chat_messages: {
      query_by: "raw",
      facet_by: "author_username,channel_name",
    },
  };

  get searchModes() {
    return [
      {
        label: "Keyword Search",
        value: "keyword",
      },
      {
        label: "Hybrid Search",
        value: "hybrid",
      },
      {
        label: "Semantic Search",
        value: "semantic",
      },
      {
        label: "Hyde Search",
        value: "hyde",
      },
    ];
  }

  @action
  changeSearchMode(newSearchMode) {
    this.searchMode = newSearchMode;
    if (this.dInstantSearch.query?.length > 0) {
      this.dInstantSearch.helper.search();
    }

    if (newSearchMode === "semantic" || newSearchMode === "hyde") {
      this.searchParameters = {
        posts: {
          query_by: "raw,topic_title",
          query_by_weights: "3,1",
          exclude_fields: "embeddings",
          facet_by:
            "author_username,category,tags,type,allowed_users,allowed_groups",
        },
        topics: {
          query_by: "title,blurb",
          exclude_fields: "embeddings",
          facet_by:
            "author_username,category,tags,type,allowed_users,allowed_groups",
        },
        users: {
          query_by: "username,name",
          facet_by: "trust_level,groups",
        },
        chat_messages: {
          query_by: "raw",
          facet_by: "author_username,channel_name",
        },
      };
    }
  }
}
