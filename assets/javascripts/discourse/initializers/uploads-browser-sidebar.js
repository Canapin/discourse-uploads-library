import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "uploads-browser-sidebar",
  initialize() {
    withPluginApi("1.31.0", (api) => {
      // This tells Discourse: "Hey, in the Admin Sidebar,
      // under the 'Plugins' section, add my page."
      api.addAdminSidebarSectionLink("plugins", {
        name: "latest-uploads",
        route: "admin.uploads", // This must match the name in your route-map.js
        label: "js.uploads_browser.title",
        icon: "file-upload", // A FontAwesome icon
      });
    });
  },
};
