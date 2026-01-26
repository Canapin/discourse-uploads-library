import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default class AdminUploadsController extends Controller {
  @service router;

  @tracked uploads = [];
  @tracked loading = false;
  @tracked canLoadMore = false;
  queryParams = ["username", "from_date", "to_date"];

  @action
  async loadMore() {
    if (this.loading || !this.canLoadMore) {
      return;
    }

    this.loading = true;
    try {
      const data = {
        username: this.username,
        from_date: this.from_date,
        to_date: this.to_date,
        offset: this.uploads.length,
      };

      const response = await ajax("/admin/uploads.json", { data });
      this.uploads = [...this.uploads, ...response.uploads];
      this.canLoadMore = response.load_more;
    } finally {
      this.loading = false;
    }
  }

  @action
  updateParams(newParams) {
    this.router.transitionTo({ queryParams: newParams });
  }

  @action
  clearFilters() {
    this.router.transitionTo({
      queryParams: { username: null, from_date: null, to_date: null },
    });
  }
}
