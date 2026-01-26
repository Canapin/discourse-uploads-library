# frozen_string_literal: true
class UploadsLibraryController < ApplicationController
  requires_plugin "discourse-uploads-library"
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
    uploads = uploads.offset(offset).limit(limit).includes(:user, posts: :topic)

    data =
      uploads.map do |u|
        is_image = u.width.present? && u.height.present?

        # Map the posts into a clean hash for the frontend
        posts_data =
          u.posts.map do |p|
            {
              id: p.id,
              url: p.url,
              post_number: p.post_number,
              topic_title: p.topic&.title,
              is_pm: p.topic&.private_message?,
            }
          end

        {
          id: u.id,
          url: is_image ? u.url : nil,
          original_url: u.url,
          name: u.original_filename,
          is_image: is_image,
          posts: posts_data,
          username: u.user&.username,
          user_id: u.user_id,
        }
      end

    render_json_dump({ uploads: data, load_more: data.length == limit })
  end
end
