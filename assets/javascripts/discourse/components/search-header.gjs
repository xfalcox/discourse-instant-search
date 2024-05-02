import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import { iconHTML } from "discourse-common/lib/icon-library";
import I18n from "discourse-i18n";

export default class SearchHeader extends Component {
  @tracked showAdvancedFilters = false;

  prefillQuery = modifier(() => {
    // Should keep previous query when switching sort modes:
    this.args.searchInstance.helper.setQuery(this.args.query).search();
  });

  get searchBoxClasses() {
    return {
      submit: ["search-cta", "btn", "btn-primary"],
      reset: ["btn", "btn-icon", "no-text"],
      input: ["search", "search-query"],
    };
  }

  get searchTypes() {
    return [
      { label: "Topics", value: "topics" },
      { label: "Posts", value: "posts" },
      { label: "Chat Messages", value: "chat_messages" },
      // { label: "Users", value: "users" },
    ];
  }

  get searchBoxTemplate() {
    return {
      // eslint-disable-next-line no-unused-vars
      submit: ({ cssClasses }, { html }) => {
        const icon = iconHTML("search");
        const label = `<span class="d-button-label">${I18n.t(
          "search.search_button"
        )}</span>`;
        const template = `${icon}\n${label}`;

        return html`${template}`;
      },
      // eslint-disable-next-line no-unused-vars
      reset: ({ cssClasses }, { html }) => {
        return html`
        <svg class="fa d-icon d-icon-times svg-icon svg-string" xmlns="http://www.w3.org/2000/svg"><use href="#times"></use></svg>
        `;
      },
    };
  }

  get hitsPerPageItems() {
    return [
      { label: "6 per page", value: 6, default: true },
      { label: "12 per page", value: 12 },
      { label: "18 per page", value: 18 },
    ];
  }

  get refinementListTemplate() {
    return {
      searchableSubmit: (data, { html }) => {
        return html`${iconHTML("search")}`;
      },
      searchableReset: (data, { html }) => {
        return html`${iconHTML("times")}`;
      },
    };
  }

  get refinementListClasses() {
    return {
      root: "refinement-list",
      searchableSubmit: ["btn", "btn-icon", "no-text"],
      searchableReset: ["btn", "btn-icon", "no-text"],
    };
  }

  @action
  toggleAdvancedFilters() {
    this.showAdvancedFilters = !this.showAdvancedFilters;
  }

  <template>
    <div class="search-header" role="search">
      <h1 class="search-page-heading">
        <@instantSearch.AisStats @searchInstance={{@searchInstance}} />
      </h1>
      <div class="search-bar" {{this.prefillQuery}}>
        <@instantSearch.AisSearchBox
          @placeholder={{i18n "search.title"}}
          @autofocus={{true}}
          @searchInstance={{@searchInstance}}
          @cssClasses={{this.searchBoxClasses}}
          @templates={{this.searchBoxTemplate}}
          @showLoadingIndicator={{false}}
          @rootClass="instant-search-box-container"
        />

        <div class="instant-search-filters">
          {{yield to="sortBy"}}
        </div>
      </div>

      <DButton
        @label="search.advanced.title"
        @icon="cog"
        @action={{this.toggleAdvancedFilters}}
      />

      {{#if this.showAdvancedFilters}}
        <div class="instant-search-refinements">
          <@instantSearch.AisRefinementList
            @searchInstance={{@searchInstance}}
            @attribute="category"
            @showMore={{false}}
            @searchable={{true}}
            @searchablePlaceholder="Search for categories"
            @cssClasses={{this.refinementListClasses}}
            @templates={{this.refinementListTemplate}}
            @rootClass="refinement-list-container"
          />
          <@instantSearch.AisRefinementList
            @searchInstance={{@searchInstance}}
            @attribute="author_username"
            @showMore={{false}}
            @searchable={{true}}
            @searchablePlaceholder="Search for users"
            @cssClasses={{this.refinementListClasses}}
            @templates={{this.refinementListTemplate}}
            @rootClass="refinement-list-container"
          />
        </div>
      {{/if}}

    </div>
  </template>
}
