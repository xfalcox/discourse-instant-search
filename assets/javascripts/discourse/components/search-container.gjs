import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseDebounce from "discourse-common/lib/debounce";
import { bind } from "discourse-common/utils/decorators";
import SearchHeader from "./search-header";
import SearchResults from "./search-results";

export default class SearchContainer extends Component {
  @service dInstantSearch;
  @tracked noLoop = false;
  @tracked uiState = null;
  @tracked loading = false;

  get customMiddleware() {
    const context = this;
    return [
      () => ({
        onStateChange({ uiState }) {
          context.uiState = uiState;
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

  async _fetchEmbeddings(uiState, setUiState, helper) {
    const query = helper.getQuery().query;
    const page = helper.getPage();

    if (!query || query?.length === 0 || page) {
      return setUiState(uiState);
    }
    this.loading = true;

    try {
      const embeddings = await ajax("/instant-search/embeddings", {
        type: "POST",
        data: JSON.stringify({
          search_query: helper.getQuery().query,
          hyde: this.args.searchMode === "hyde",
        }),
        contentType: "application/json",
      }).then((response) => {
        this.loading = false;
        return response.embeddings;
      });

      if (
        this.args.searchMode === "semantic" ||
        this.args.searchMode === "hyde"
      ) {
        helper
          .setQueryParameter(
            "typesenseVectorQuery",
            `embeddings:([${embeddings.join(",")}], k:1000)`
          )
          .setQueryParameter("query", "*");
        return setUiState(uiState);
      } else {
        // hybrid
        helper.setQueryParameter(
          "typesenseVectorQuery",
          `embeddings:([${embeddings.join(",")}], k:1000)`
        );
        return setUiState(uiState);
      }
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @bind
  async onStateChange({ uiState, setUiState }) {
    const helper = this.dInstantSearch.searchInstance.helper;

    if (
      this.args.searchMode === "keyword" ||
      this.args.searchType === "user" ||
      this.args.searchType === "chat_message"
    ) {
      helper.setQueryParameter("typesenseVectorQuery", null);
      return setUiState(uiState);
    }

    discourseDebounce(
      this,
      this._fetchEmbeddings,
      uiState,
      setUiState,
      helper,
      1000
    );
  }

  @action
  initSearchInstance(element, searchInstance) {
    this.dInstantSearch.searchInstance = searchInstance[0];
  }

  <template>
    <@instantSearch.AisInstantSearch
      @apiData={{@apiData}}
      @middleware={{this.customMiddleware}}
      @collectionSpecificSearchParameters={{@searchParameters}}
      @onStateChange={{this.onStateChange}}
      as |Ais|
    >
      <section
        class="search-container instant-search-container"
        {{didInsert this.initSearchInstance Ais.searchInstance}}
      >
        <SearchHeader
          @instantSearch={{@instantSearch}}
          @searchInstance={{Ais.searchInstance}}
          @query={{@query}}
          @searchType={{@searchType}}
          @uiState={{this.uiState}}
          @searchModes={{@searchModes}}
          @searchMode={{@searchMode}}
        >
          <:sortBy>
            {{yield to="sortBy"}}
          </:sortBy>
        </SearchHeader>

        <ConditionalLoadingSpinner @condition={{this.loading}} />

        <div class="search-advanced">
          <SearchResults
            @loading={{this.loading}}
            @query={{@query}}
            @instantSearch={{@instantSearch}}
            @searchInstance={{Ais.searchInstance}}
            @searchType={{@searchType}}
          />
        </div>
      </section>
    </@instantSearch.AisInstantSearch>
  </template>
}
