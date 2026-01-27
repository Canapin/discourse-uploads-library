import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  updateCurrentUser,
} from "discourse/tests/helpers/qunit-helpers";

const state = { usernameParam: null };

const allUploads = [
  {
    id: 1,
    name: "old_file.jpg",
    username: "Arkshine",
    created_at: "2023-01-01",
  },
  {
    id: 2,
    name: "mid_file.jpg",
    username: "Lilly",
    created_at: "2024-01-01",
  },
  {
    id: 3,
    name: "new_file.jpg",
    username: "Moin",
    created_at: "2025-01-01",
  },
];

acceptance("Uploads Library - Permissions", function (needs) {
  needs.user({ admin: true });

  needs.hooks.beforeEach(function () {
    state.usernameParam = null;
    state.capturedParams = null;
  });

  needs.pretender((server, helper) => {
    server.get("/admin/uploads.json", (request) => {
      state.usernameParam = request.queryParams.username;

      const { from_date, to_date } = request.queryParams;

      let filtered = [...allUploads];

      if (state.usernameParam) {
        filtered = filtered.filter((u) => u.username === state.usernameParam);
      }

      if (from_date) {
        filtered = filtered.filter((u) => u.created_at >= from_date);
      }
      if (to_date) {
        filtered = filtered.filter((u) => u.created_at <= to_date);
      }

      return helper.response({ uploads: filtered, load_more: false });
    });

    server.get("/u/search/users", () => {
      return helper.response({
        users: [
          {
            username: "Arkshine",
            avatar_template: "/letter_index/u/{size}.png",
          },
        ],
      });
    });
  });

  test("Admins can access the uploads library", async function (assert) {
    updateCurrentUser({ admin: true });

    await visit("/admin/uploads");

    assert
      .dom(".admin-uploads-library-container")
      .exists("Admin is allowed access and the page rendered");
  });

  test("Regular users cannot access the uploads library", async function (assert) {
    updateCurrentUser({ admin: false });

    try {
      await visit("/admin/uploads");
    } catch {}

    assert
      .dom(".admin-uploads-library-container")
      .doesNotExist("The admin container is blocked by the route guard");

    assert.notEqual(
      window.location.pathname,
      "/admin/uploads",
      "User was successfully redirected away from the admin route"
    );
  });

  test("Moderators cannot access the uploads library", async function (assert) {
    updateCurrentUser({ admin: false, moderator: true });

    try {
      await visit("/admin/uploads");
    } catch {}

    assert
      .dom(".admin-uploads-library-container")
      .doesNotExist("The admin container is blocked by the route guard");

    assert.notEqual(
      window.location.pathname,
      "/admin/uploads",
      "Moderator was successfully redirected away from the admin route"
    );
  });

  test("Loading the page with a username in the URL filters the results immediately", async function (assert) {
    updateCurrentUser({ admin: true });

    await visit("/admin/uploads?username=Arkshine");

    assert.strictEqual(
      state.usernameParam,
      "Arkshine",
      "The API was called with the correct username from the URL"
    );

    assert
      .dom(".upload-card")
      .exists({ count: 1 }, "Only one upload is displayed");
    assert
      .dom(".upload-user")
      .includesText("@Arkshine", "The displayed upload belongs to Arkshine");
  });

  test("Library should show all users' uploads by default", async function (assert) {
    updateCurrentUser({ admin: true });

    await visit("/admin/uploads");

    assert.notOk(
      state.usernameParam,
      "API was called without a username parameter"
    );

    assert
      .dom(".upload-card")
      .exists({ count: 3 }, "The gallery shows all available uploads");
  });

  test("Filtering by to_date excludes newer files", async function (assert) {
    updateCurrentUser({ admin: true });

    await visit("/admin/uploads?to_date=2024-12-31");

    assert
      .dom(".upload-card")
      .exists({ count: 2 }, "Shows 2 uploads created before 2025");
    assert.dom(".upload-card").doesNotIncludeText("new_file.jpg");
  });
});
