import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "uploads-library-sidebar",
  initialize() {
    withPluginApi((api) => {
      api.addAdminSidebarSectionLink("security", {
        name: "uploads-library",
        route: "admin.uploads",
        label: "js.uploads_library.title",
        icon: "images",
      });
    });
  },
};
