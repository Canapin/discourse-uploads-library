import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "uploads-browser-sidebar",
  initialize() {
    withPluginApi("1.31.0", (api) => {
      api.addAdminSidebarSectionLink("security", {
        name: "latest-uploads",
        route: "admin.uploads",
        label: "js.uploads_browser.title",
        icon: "images",
      });
    });
  },
};
