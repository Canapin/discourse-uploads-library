import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class AdminUploadsRoute extends DiscourseRoute {
  @service currentUser;
  @service router;

  beforeModel() {
    if (!this.currentUser?.admin) {
      return this.router.transitionTo("discovery.latest");
    }
  }
  queryParams = {
    username: { refreshModel: true },
    from_date: { refreshModel: true },
    to_date: { refreshModel: true },
  };

  model(params) {
    return ajax("/admin/uploads.json", { data: { ...params, offset: 0 } });
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.uploads = [...(model.uploads || [])];
    controller.canLoadMore = model.load_more;
  }
}
