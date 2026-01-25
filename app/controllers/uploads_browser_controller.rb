# frozen_string_literal: true
class UploadsBrowserController < ApplicationController
  requires_plugin "uploads-browser"
  skip_before_action :check_xhr, :verify_authenticity_token

  def index
    raise Discourse::InvalidAccess.new unless guardian.is_admin?

    uploads = Upload.order(created_at: :desc)

    if params[:username].present?
      user = User.find_by_username(params[:username])
      uploads = uploads.where(user_id: user.id) if user
    end

    if params[:from_date].present?
      uploads = uploads.where("created_at >= ?", params[:from_date].to_date.beginning_of_day)
    end

    if params[:to_date].present?
      uploads = uploads.where("created_at <= ?", params[:to_date].to_date.end_of_day)
    end

    limit = 30
    offset = params[:offset].to_i || 0
    uploads = uploads.offset(offset).limit(limit)

    data =
      uploads.map do |u|
        is_image = u.width.present? && u.height.present?
        {
          id: u.id,
          url: is_image ? u.url : nil,
          original_url: u.short_path,
          name: u.original_filename,
          is_image: is_image,
        }
      end

    render_json_dump({ uploads: data, load_more: data.length == limit })
  end
end
