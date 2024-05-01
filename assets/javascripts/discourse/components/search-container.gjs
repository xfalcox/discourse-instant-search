import Component from "@glimmer/component";
import SearchHeader from "./search-header";
import SearchResults from "./search-results";

export default class SearchContainer extends Component {
  get customMiddleware() {
    const context = this;
    return [
      () => ({
        onStateChange({ uiState }) {
          const searchType = context.args.searchType;
          const currentSearchType = uiState[searchType];

          if (currentSearchType?.query) {
            context.args.updateQuery(currentSearchType.query);
          }
        },
        subscribe() {},
        unsubscribe() {},
      }),
    ];
  }

  <template>
    <@instantSearch.AisInstantSearch
      @apiData={{@apiData}}
      @middleware={{this.customMiddleware}}
      @collectionSpecificSearchParameters={{@searchParameters}}
      as |Ais|
    >
      <section class="search-container instant-search-container">
        <SearchHeader
          @instantSearch={{@instantSearch}}
          @searchInstance={{Ais.searchInstance}}
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
