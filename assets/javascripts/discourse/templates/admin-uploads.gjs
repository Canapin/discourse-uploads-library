import RouteTemplate from "ember-route-template";
import AdminUploadsManager from "../components/admin-uploads-manager";

export default RouteTemplate(
  <template>
    <AdminUploadsManager
      @uploads={{@controller.uploads}}
      @loading={{@controller.loading}}
      @canLoadMore={{@controller.canLoadMore}}
      @loadMore={{@controller.loadMore}}
      @username={{@controller.username}}
      @fromDate={{@controller.from_date}}
      @toDate={{@controller.to_date}}
      @onChangeParams={{@controller.updateParams}}
      @onClear={{@controller.clearFilters}}
    />
  </template>
);
