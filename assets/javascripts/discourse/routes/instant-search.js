import { ajax } from "discourse/lib/ajax";
import { escapeExpression } from "discourse/lib/utilities";
import DiscourseRoute from "discourse/routes/discourse";
import I18n from "discourse-i18n";

export default DiscourseRoute.extend({
  titleToken() {
    return I18n.t("search.results_page", {
      term: escapeExpression(
        this.controllerFor("instant-search").dInstantSearch.query
      ),
    });
  },

  model() {
    return ajax("/instant-search/key");
  },
});
