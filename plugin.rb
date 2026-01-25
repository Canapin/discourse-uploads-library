# name: uploads-browser
# about: List last 100 uploads in the Admin panel
# version: 0.6
# authors: Gemini
# url: https://github.com/your-repo/uploads-browser

enabled_site_setting :uploads_browser_enabled

# 1. Load the CSS for the grid layout
register_asset "stylesheets/common/uploads-browser.scss"

after_initialize do
  # 2. Force load the controller to prevent "Uninitialized Constant" errors
  require_dependency File.expand_path("../app/controllers/uploads_browser_controller.rb", __FILE__)

  Discourse::Application.routes.append do
    # 3. The Data Endpoint (Returns JSON)
    #    This is hit by the Ember Javascript to get the list of files.
    get "/admin/uploads.json" => "uploads_browser#index"

    # 4. The Browser Route (Loads the Admin UI)
    #    We point this to the main Admin Plugins controller.
    #    The EmberJS router will see the URL is '/admin/uploads' and render your template.
    get "/admin/uploads" => "admin/plugins#index"
  end
end
