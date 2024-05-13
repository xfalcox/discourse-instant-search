import { tracked } from "@glimmer/tracking";
import Service from "@ember/service";

export default class DInstantSearch extends Service {
  @tracked searchInstance = null;
  @tracked helper = this.searchInstance ? this.searchInstance.helper : null;
}
