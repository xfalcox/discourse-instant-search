import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { eq } from "truth-helpers";
import loadInstantSearch from "discourse/lib/load-instant-search";
import ComboBox from "select-kit/components/combo-box";
import { SEARCH_TYPES } from "../lib/constants";
import SearchContainer from "./search-container";

export default class SearchWrapper extends Component {
  @service siteSettings;
  @tracked instantSearchModule;
  @tracked searchType = this.searchTypes[0].value;
  @tracked embeddings = [];
  @tracked apiKey = this.args.model.api_key;
  @tracked categoriesList = this.args.model.categories_list;

  constructor() {
    super(...arguments);
    this.loadInstantSearch();
  }

  get searchTypes() {
    return [
      {
        label: "Topics",
        value: SEARCH_TYPES.topics,
      },
      {
        label: "Posts",
        value: SEARCH_TYPES.posts,
      },
      {
        label: "Chat Messages",
        value: SEARCH_TYPES.chat_messages,
      },
      {
        label: "Users",
        value: SEARCH_TYPES.users,
      },
    ];
  }
  get apiData() {
    if (!this.siteSettings.proxy_typesense_requests) {
      const typesenseNodes = JSON.parse(this.siteSettings.typesense_nodes);

      return {
        apiKey: this.apiKey,
        port: typesenseNodes[0].port,
        host: typesenseNodes[0].host,
        protocol: typesenseNodes[0].protocol,
        indexName: this.searchType,
        queryBy: this.args.searchParameters[this.searchType].query_by,
      };
    } else {
      return {
        apiKey: this.apiKey,
        path: "/typesense",
        port: window.location.port || 443,
        host: window.location.hostname,
        protocol: window.location.protocol.replace(":", ""),
        indexName: this.searchType,
        queryBy: this.args.searchParameters[this.searchType].query_by,
      };
    }
  }

  async loadInstantSearch() {
    this.instantSearchModule = await loadInstantSearch();
  }

  get instantSearch() {
    return this.instantSearchModule;
  }

  <template>
    {{#if (eq this.searchType "topics")}}
      <SearchContainer
        @apiData={{this.apiData}}
        @instantSearch={{this.instantSearch}}
        @searchType={{this.searchType}}
        @searchParameters={{@searchParameters}}
        @searchMode={{@searchMode}}
        @categoriesList={{this.categoriesList}}
      >
        <:searchMode>
          {{yield to="searchMode"}}
        </:searchMode>
        <:sortBy>
          <ComboBox
            class="search-types"
            @valueProperty="value"
            @content={{this.searchTypes}}
            @value={{this.searchType}}
          />
        </:sortBy>
      </SearchContainer>
    {{else if (eq this.searchType "posts")}}
      <SearchContainer
        @apiData={{this.apiData}}
        @instantSearch={{this.instantSearch}}
        @searchType={{this.searchType}}
        @searchParameters={{@searchParameters}}
        @searchMode={{@searchMode}}
        @categoriesList={{this.categoriesList}}
      >
        <:searchMode>
          {{yield to="searchMode"}}
        </:searchMode>
        <:sortBy>
          <ComboBox
            class="search-types"
            @valueProperty="value"
            @content={{this.searchTypes}}
            @value={{this.searchType}}
          />
        </:sortBy>
      </SearchContainer>
    {{else if (eq this.searchType "chat_messages")}}
      <SearchContainer
        @apiData={{this.apiData}}
        @instantSearch={{this.instantSearch}}
        @searchType={{this.searchType}}
        @searchParameters={{@searchParameters}}
        @searchMode={{@searchMode}}
        @categoriesList={{this.categoriesList}}
      >
        <:searchMode>
          {{yield to="searchMode"}}
        </:searchMode>
        <:sortBy>
          <ComboBox
            class="search-types"
            @valueProperty="value"
            @content={{this.searchTypes}}
            @value={{this.searchType}}
          />
        </:sortBy>
      </SearchContainer>
    {{else if (eq this.searchType "users")}}
      <SearchContainer
        @apiData={{this.apiData}}
        @instantSearch={{this.instantSearch}}
        @searchType={{this.searchType}}
        @searchParameters={{@searchParameters}}
        @searchMode={{@searchMode}}
        @categoriesList={{this.categoriesList}}
      >
        <:searchMode>
          {{yield to="searchMode"}}
        </:searchMode>
        <:sortBy>
          <ComboBox
            class="search-types"
            @valueProperty="value"
            @content={{this.searchTypes}}
            @value={{this.searchType}}
          />
        </:sortBy>
      </SearchContainer>
    {{/if}}
  </template>
}
