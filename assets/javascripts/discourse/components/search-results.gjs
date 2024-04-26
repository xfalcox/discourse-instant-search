import Component from "@glimmer/component";
import { relativeAge } from "discourse/lib/formatter";

export default class SearchResults extends Component {
  get infiniteHitsClasses() {
    return {
      root: "",
      list: "fps-result-entries",
      item: "fps-result",
      loadMore: ["btn"],
    };
  }

  get customHitTemplate() {
    return {
      item: (hit) => {
        switch (this.args.searchType) {
          case "topics":
            return this.topicsHitTemplate(hit);
          case "posts":
            return this.postsHitTemplate(hit);
          case "chat_messages":
            return this.chatMessagesHitTemplate(hit);
          case "users":
            return this.usersHitTemplate(hit);
          default:
            return this.topicsHitTemplate(hit);
        }
      },
    };
  }

  topicsHitTemplate(hit) {
    const author = this.buildAuthorHTML(hit.author_username);
    const date = this.buildDateHTML(hit.created_at);
    const category = hit.category ? this.buildCategoryHTML(hit.category) : "";

    const highlightedTitle = hit._highlightResult.title.value || hit.title;
    const title = this.buildTitleHTML(highlightedTitle, `/t/${hit.id}`);

    const highlightedBlurb = hit._highlightResult.blurb.value || hit.blurb;
    const content = this.buildContentHTML(highlightedBlurb);
    const template = `
          ${author}
          <div class="fps-topic">
            ${title}
            ${category}
            <div class="blurb container">
            ${date}
            ${content}
            </div>
          </div>
          `;

    return template;
  }

  postsHitTemplate(hit) {
    const highlightedTitle =
      hit._highlightResult.topic_title?.value || hit.topic_title;
    const title = this.buildTitleHTML(highlightedTitle, `/p/${hit.id}`);
    const highlightedContent =
      hit._highlightedResult?.cooked?.value || hit?.cooked;
    const content = hit.cooked ? this.buildContentHTML(highlightedContent) : "";

    const author = this.buildAuthorHTML(hit.author_username);
    const date = this.buildDateHTML(hit.created_at);
    return `
          ${author}
          <div class="fps-topic">
            ${title}
            <div class="blurb container">
            ${date}
            ${content}
            </div>
          </div>
          `;
  }

  chatMessagesHitTemplate(hit) {
    const authorHTML = this.buildAuthorHTML(hit.author_username);
    const highlightedtitle =
      hit._highlightResult?.author_username?.value || hit.author_username;
    const title = this.buildUsernameTitle(highlightedtitle);
    const date = this.buildDateHTML(hit.created_at);
    const highlightedContent =
      hit._highlightedResult?.cooked?.value || hit?.cooked;
    const content = hit.cooked ? this.buildContentHTML(highlightedContent) : "";

    return `
      ${authorHTML}
      <div class="fps-topic">
        ${title}
        <div class="blurb container">
        ${date}
        ${content}
        </div>
      </div>
    `;
  }

  usersHitTemplate(hit) {
    const authorHTML = this.buildAuthorHTML(hit.username);
    const highlightedtitle =
      hit._highlightResult?.username?.value || hit.username;
    const title = this.buildUsernameTitle(highlightedtitle);
    const date = this.buildDateHTML(hit.created_at);

    return `
      ${authorHTML}
      <div class="fps-topic">
        ${title}
        <div class="blurb container">
        ${date}
        </div>
      </div>
    `;
  }

  buildContentHTML(content) {
    return `
      <div class="blurb container">
        ${content}
      </div>
    `;
  }

  buildUsernameTitle(username) {
    return `
      <div class="topic">
        <a href="/u/${username}" class="search-link" role="heading">
          <span class="topic-title">
            ${username}
          </span>
        </a>
      </div>
     `;
  }

  buildTitleHTML(title, url) {
    return `
      <div class="topic">
        <a href="${url}" class="search-link" role="heading">
          <span class="topic-title">
            ${title}
          </span>
        </a>
      </div>
     `;
  }

  buildDateHTML(date) {
    const dateValue = new Date(date * 1000);
    const formattedDate = relativeAge(dateValue);
    return `
      <div class="date">
        <span class="relative-date">${formattedDate}</span>
      </div>
    `;
  }

  buildAuthorHTML(username) {
    // TODO: Improve way of getting avatar src.
    const avatarSrc = `https://meta.discourse.org/user_avatar/meta.discourse.org/${username}/48/176214_2.png`;
    return `
        <div class="author">
          <a href="/u/${username}" data-user-card="${username}"><img src="${avatarSrc}" width="48" height="48" class="avatar" title="${username}"/></a>
        </div>
      `;
  }

  buildCategoryHTML(category) {
    // TODO: Get proper category id and category badge color.
    return `
      <div class="search-category">
        <a href="/c/${category}" class="badge-category__wrapper" style="--category-badge-color: #00A94F">
          <span class="badge-category">
            <span class="badge-category__name">${category}</span>
          </span>
        </a>
      </div>`;
  }

  <template>
    <div class="search-results --{{this.args.searchType}}" role="region">
      <@instantSearch.AisInfiniteHits
        @searchInstance={{@searchInstance}}
        @templates={{this.customHitTemplate}}
        @cssClasses={{this.infiniteHitsClasses}}
      />
    </div>
  </template>
}
