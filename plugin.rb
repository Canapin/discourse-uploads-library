# name: discourse-uploads-library
# about: Browse user uploads from the admin panel.
# version: 1.0
# authors: Canapin & AI
# url: https://github.com/Canapin/discourse-uploads-library

enabled_site_setting :uploads_library_enabled

register_asset "stylesheets/common/uploads-library.scss"

after_initialize do
  require_dependency File.expand_path("../app/controllers/uploads_library_controller.rb", __FILE__)

  Discourse::Application.routes.append do
    get "/admin/uploads.json" => "uploads_library#index"
    get "/admin/uploads" => "admin/plugins#index"
  end
end
