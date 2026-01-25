import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class AdminUploadsRoute extends Route {
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
