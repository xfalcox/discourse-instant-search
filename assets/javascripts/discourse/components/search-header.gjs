import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import { iconHTML } from "discourse-common/lib/icon-library";
import I18n from "discourse-i18n";
import ComboBox from "select-kit/components/combo-box";

export default class SearchHeader extends Component {
  @service dInstantSearch;
  @tracked showAdvancedFilters = false;

  prefillQuery = modifier(() => {
    // Should keep previous query when switching sort modes:
    if (this.args.query?.length > 0) {
      this.args.searchInstance.helper.setQuery(this.args.query);
    }
  });

  get searchBoxClasses() {
    return {
      submit: ["search-cta", "btn", "btn-primary"],
      reset: ["btn", "btn-icon", "no-text"],
      input: ["search", "search-query"],
    };
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

  get showTypeRefinementList() {
    return (
      this.args.searchType === "topics" || this.args.searchType === "posts"
    );
  }

  get showCategoryRefinementList() {
    const typeRefinements = this.dInstantSearch.helper
      .getRefinements("type")
      .map(({ value }) => value);

    if (typeRefinements.includes("private_message")) {
      return false;
    }
    return (
      this.args.searchType === "topics" || this.args.searchType === "posts"
    );
  }

  get showUserRefinementList() {
    return (
      this.args.searchType === "topics" ||
      this.args.searchType === "posts" ||
      this.args.searchType === "chat_messages"
    );
  }

  get showTagRefinementList() {
    return (
      this.args.searchType === "topics" || this.args.searchType === "posts"
    );
  }

  get showTrustRefinementList() {
    return this.args.searchType === "users";
  }

  get showGroupRefinementList() {
    return this.args.searchType === "users";
  }

  get showAdvancedFiltersButton() {
    return this.args.query?.length > 0;
  }

  get showAllowedUsersAndGroupsList() {
    return (
      this.args.searchType === "topics" || this.args.searchType === "posts"
    );
  }

  @action
  toggleAdvancedFilters() {
    this.showAdvancedFilters = !this.showAdvancedFilters;
  }

  <template>
    <div class="search-header" role="search">
      <h1 class="search-page-heading">
        <div class="instant-search-mode">
          {{yield to="searchMode"}}
        </div>

        {{#if @query}}
          <span class="search-page-heading__stats">
            <@instantSearch.AisStats @searchInstance={{@searchInstance}} />
          </span>
        {{/if}}
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

      {{#if this.showAdvancedFiltersButton}}
        <DButton
          @label="search.advanced.title"
          @icon="cog"
          @action={{this.toggleAdvancedFilters}}
        />
      {{/if}}

      {{#if this.showAdvancedFilters}}
        <div class="instant-search-refinements">
          {{#if this.showTypeRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="type"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for type"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container type-refinment"
            />
          {{/if}}
          {{#if this.showCategoryRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="category"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for categories"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container category-refinement"
            />
          {{/if}}
          {{#if this.showUserRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="author_username"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for users"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container user-refinement"
            />
          {{/if}}
          {{#if this.showTagRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="tags"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for tags"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container tag-refinement"
            />
          {{/if}}
          {{#if this.showTrustRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="trust_level"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for Trust Levels"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container trust-level-refinement"
            />
          {{/if}}
          {{#if this.showGroupRefinementList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="groups"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Search for Groups"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container group-refinement"
            />
          {{/if}}

          {{#if this.showAllowedUsersAndGroupsList}}
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="allowed_users"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Filter to a PM recipient"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container allowed-users-refinement"
            />
            <@instantSearch.AisRefinementList
              @searchInstance={{@searchInstance}}
              @attribute="allowed_groups"
              @showMore={{false}}
              @searchable={{true}}
              @searchablePlaceholder="Filter to an inbox"
              @cssClasses={{this.refinementListClasses}}
              @templates={{this.refinementListTemplate}}
              @rootClass="refinement-list-container allowed-groups-refinement"
            />
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
