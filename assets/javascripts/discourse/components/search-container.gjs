import Component from "@glimmer/component";
import { tracked } from '@glimmer/tracking';
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse-common/utils/decorators";
import SearchHeader from "./search-header";
import SearchResults from "./search-results";

export default class SearchContainer extends Component {
  @tracked noLoop = false;

  get customMiddleware() {
    const context = this;
    return [
      () => ({
        onStateChange({ uiState }) {
          const searchType = context.args.searchType;
          const currentSearchType = uiState[searchType];
          if (currentSearchType?.query) {
            context.args.updateQuery(currentSearchType.query);
          } else {
            context.args.updateQuery("");
          }
        },
        subscribe() {},
        unsubscribe() {},
      }),
    ];
  }

  @bind
  async searchFunction(helper) {
    const query = helper.getQuery().query;
    const page = helper.getPage();

    if (query === "") {
      return;
    }

    if (
      this.args.searchMode === "keyword" ||
      this.args.searchType === "user" ||
      this.args.searchType === "chat_message"
    ) {
      helper.setQueryParameter("typesenseVectorQuery", null).search();
      return;
    }

    const embeddings = await ajax("/instant-search/embeddings", {
      type: "POST",
      data: JSON.stringify({
        search_query: this.args.query,
        hyde: this.args.searchMode === "hyde",
      }),
      contentType: "application/json",
    }).then((response) => {
      return response.embeddings;
    });

    if (this.args.searchMode === "semantic" || this.args.searchMode === "hyde") {
      helper
        .setQueryParameter(
          "typesenseVectorQuery",
          `embeddings:([${embeddings.join(",")}], k:1000)`,
        )
        .setQueryParameter("query", "*")
        .setPage(page)
        .search();
    } else {
      // hybrid
      helper
        .setQueryParameter(
          "typesenseVectorQuery",
          `embeddings:([${embeddings.join(",")}], k:1000)`,
        )
        .setPage(page)
        .search();
    }
  }


  <template>
    <@instantSearch.AisInstantSearch
      @apiData={{@apiData}}
      @middleware={{this.customMiddleware}}
      @collectionSpecificSearchParameters={{@searchParameters}}
      @searchFunction={{this.searchFunction}}
      as |Ais|
    >
      <section class="search-container instant-search-container">
        <SearchHeader
          @instantSearch={{@instantSearch}}
          @searchInstance={{Ais.searchInstance}}
          @query={{@query}}
          @searchType={{@searchType}}
        >
          <:sortBy>
            {{yield to="sortBy"}}
          </:sortBy>
        </SearchHeader>

        <div class="search-advanced">
          <SearchResults
            @instantSearch={{@instantSearch}}
            @searchInstance={{Ais.searchInstance}}
            @searchType={{@searchType}}
          />
        </div>
      </section>
    </@instantSearch.AisInstantSearch>
  </template>
}
