import Component from "@glimmer/component";
import { eq } from "truth-helpers";
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
    const category =
      hit.category && hit.tags
        ? this.buildCategoryHTML(hit.category, hit.tags, hit.category_id)
        : "";

    const highlightedTitle = hit._highlightResult.title.value || hit.title;
    const title = this.buildTitleHTML(
      highlightedTitle,
      `/t/${hit.id}`,
      hit.type,
      hit.closed
    );

    const highlightedBlurb = hit._highlightResult.blurb.value || hit.blurb;
    const content = this.buildContentHTML(highlightedBlurb);
    const template = `
          <div class="fps-topic">
            ${title}
            ${category}
            <div class="blurb container">
              ${content}
            </div>
              ${author}
              ${date}
          </div>
          `;

    return template;
  }

  postsHitTemplate(hit) {
    const highlightedTitle =
      hit._highlightResult.topic_title?.value || hit.topic_title;
    const title = this.buildTitleHTML(
      highlightedTitle,
      `/p/${hit.id}`,
      hit.type
    );
    const snippetContent = hit._snippetResult?.raw?.value || hit?.raw;
    const content = hit.raw ? this.buildContentHTML(snippetContent) : "";
    const category =
      hit.category && hit.tags
        ? this.buildCategoryHTML(hit.category, hit.tags, hit.category_id)
        : "";
    const author = this.buildAuthorHTML(hit.author_username);
    const date = this.buildDateHTML(hit.created_at);

    return `
          <div class="post-result">
            <div class="post-result__avatar">
              ${author}
            </div>
            <div class="post-result__title">
              ${title}
              ${category}
            </div>
            <div class="post-result__excerpt">
              <span class="first username">
                ${hit.author_username}
              </span>
              ${content}
              ${date}
            </div>
          </div>
          `;
  }

  chatMessagesHitTemplate(hit) {
    const authorHTML = this.buildAuthorHTML(hit.author_username);
    const highlightedtitle =
      hit._highlightResult?.author_username?.value || hit.author_username;
    const title = this.buildUsernameTitle(highlightedtitle);
    const channel = this.buildChannelHTML(
      hit.channel_name,
      hit.channel_id,
      hit.id
    );
    const date = this.buildDateHTML(hit.created_at);
    const highlightedContent = hit._highlightResult?.raw?.value || hit?.raw;
    const content = hit.raw ? this.buildContentHTML(highlightedContent) : "";

    return `
    <div class="chat-result">
      ${channel}
      ${authorHTML} 
      <div class="fps-topic">
        ${title} ${date}
        <div class="blurb container">
        ${content}
        </div>
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
    <div class="user-result">
      <div class="user-result__user">
        ${authorHTML}
        <div class="fps-topic">
          ${title}
        </div>
      </div> 
      <div class="user-result__likes-received --stat">
        ${hit.likes_received}
      </div>
      <div class="user-result__likes-given --stat">
        ${hit.likes_given}
      </div>
      <div class="user-result__topics-created --stat">
        ${hit.topics_created}
      </div>
      <div class="user-result__replies-created --stat">
        ${hit.posts_created}
      </div>
      <div class="user-result__account-created">
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

  buildTitleHTML(title, url, type, closed) {
    const svgEnvelope = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--!Font Awesome Free 6.5.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.--><path d="M48 64C21.5 64 0 85.5 0 112c0 15.1 7.1 29.3 19.2 38.4L236.8 313.6c11.4 8.5 27 8.5 38.4 0L492.8 150.4c12.1-9.1 19.2-23.3 19.2-38.4c0-26.5-21.5-48-48-48H48zM0 176V384c0 35.3 28.7 64 64 64H448c35.3 0 64-28.7 64-64V176L294.4 339.2c-22.8 17.1-54 17.1-76.8 0L0 176z"/></svg>`;
    const typeIcon = type === "private_message" ? svgEnvelope : "";

    const svgLock = `<svg class="lock" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><!--!Font Awesome Free 6.5.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.--><path d="M144 144v48H304V144c0-44.2-35.8-80-80-80s-80 35.8-80 80zM80 192V144C80 64.5 144.5 0 224 0s144 64.5 144 144v48h16c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V256c0-35.3 28.7-64 64-64H80z"/></svg>`;
    const closedIcon = closed ? svgLock : "";

    return `
      <div class="topic">
        <a href="${url}" class="search-link" role="heading">
          <span class="topic-title">
           ${closedIcon} ${typeIcon} ${title}
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
        <span>${formattedDate}</span>
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

  buildTagsHTML(tags) {
    const tagsHTML = [];
    tags.forEach((tag) => {
      tagsHTML.push(
        `<a href="/tags/${tag}" class="discourse-tag simple" data-tag-name="${tag}">${tag}</a>`
      );
    });

    const tagsWrapper = `
      <div class="discourse-tags" role="list" aria-label="Tags">
        ${tagsHTML.join("")}
      </div>
    `;

    return tagsWrapper;
  }

  buildCategoryHTML(category, tags, category_id) {
    const categoryData = this.args.categoriesList.find(
      (cat) => cat.id === category_id
    );

    const categoryParentData = categoryData?.parent_category_id
      ? this.args.categoriesList.find(
          (cat) => cat.id === categoryData.parent_category_id
        )
      : null;

    const categoryParentColor = categoryParentData
      ? `--parent-category-badge-color: #${categoryParentData.color};`
      : "";

    const hasParent = categoryParentData ? "--has-parent" : "";

    return `
      <div class="search-category">
        <a href="/c/${category}" class="badge-category__wrapper" style="--category-badge-color: #${
      categoryData.color
    }; ${categoryParentColor}">
          <span class="badge-category ${hasParent}">
            <span class="badge-category__name">${category}</span>
          </span>
        </a>
        ${this.buildTagsHTML(tags)}
      </div>`;
  }

  buildChannelHTML(channel, channel_id, id) {
    // TODO: Get proper category id and category badge color.

    const chatSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--!Font Awesome Free 6.5.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.--><path d="M512 240c0 114.9-114.6 208-256 208c-37.1 0-72.3-6.4-104.1-17.9c-11.9 8.7-31.3 20.6-54.3 30.6C73.6 471.1 44.7 480 16 480c-6.5 0-12.3-3.9-14.8-9.9c-2.5-6-1.1-12.8 3.4-17.4l0 0 0 0 0 0 0 0 .3-.3c.3-.3 .7-.7 1.3-1.4c1.1-1.2 2.8-3.1 4.9-5.7c4.1-5 9.6-12.4 15.2-21.6c10-16.6 19.5-38.4 21.4-62.9C17.7 326.8 0 285.1 0 240C0 125.1 114.6 32 256 32s256 93.1 256 208z"/></svg>`;
    const channelName = channel || "-";
    const channelDisplayName = channel || "message expired";
    const channelUrl = `/chat/c/${channelName}/${channel_id}/${id}`;
    const disabled = channel ? "" : `disabled`;
    const seeIn = channel ? "See in" : "";

    return `
      <div class="chat-result__channel">
        <a href="${channelUrl}" ${disabled} style="--category-badge-color: #00A94F">
            <span class="chat-result__channel-name">${seeIn} ${chatSvg} ${channelDisplayName}</span>
        </a>
      </div>`;
  }

  get hasQuery() {
    return this.args.query.length > 0;
  }

  <template>
    {{#if this.hasQuery}}
      <div class="search-results --{{@searchType}}" role="region">
        {{#if (eq @searchType "users")}}
          <div class="--heading">
            <span>Username</span>
            <span class="--stat">Likes received</span>
            <span class="--stat">Likes given</span>
            <span class="--stat">Topics created</span>
            <span class="--stat">Replies</span>
            <span>Created</span>
          </div>
        {{/if}}
        <@instantSearch.AisInfiniteHits
          @searchInstance={{@searchInstance}}
          @templates={{this.customHitTemplate}}
          @cssClasses={{this.infiniteHitsClasses}}
        />
      </div>
    {{/if}}
  </template>
}
