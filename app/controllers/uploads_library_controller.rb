# frozen_string_literal: true

class UploadsLibraryController < ApplicationController
  requires_plugin "discourse-uploads-library"
  skip_before_action :check_xhr, :verify_authenticity_token

  PAGE_SIZE = 30

  def index
    raise Discourse::InvalidAccess.new unless guardian.is_admin?

    uploads = fetch_filtered_uploads

    data = serialize_uploads(uploads)

    render_json_dump({ uploads: data, load_more: data.length == PAGE_SIZE })
  end

  private

  def fetch_filtered_uploads
    uploads = Upload.includes(:user, :optimized_images, posts: :topic)

    uploads = filter_by_user(uploads)
    uploads = filter_by_date(uploads)

    uploads.order(created_at: :desc).offset(params[:offset].to_i).limit(PAGE_SIZE)
  end

  def filter_by_user(uploads)
    return uploads if params[:username].blank?

    user = User.find_by_username(params[:username])
    user ? uploads.where(user_id: user.id) : uploads.none
  end

  def filter_by_date(uploads)
    if params[:from_date].present?
      uploads = uploads.where("created_at >= ?", params[:from_date].to_date.beginning_of_day)
    end

    if params[:to_date].present?
      uploads = uploads.where("created_at <= ?", params[:to_date].to_date.end_of_day)
    end

    uploads
  end

  def serialize_uploads(uploads)
    uploads.map do |upload|
      is_image = upload.width.present? && upload.height.present?

      {
        id: upload.id,
        thumbnail_url: is_image ? upload.get_optimized_image(400, 400, {})&.url : nil,
        url: upload.url,
        name: upload.original_filename,
        is_image: is_image,
        username: upload.user&.username,
        user_id: upload.user_id,
        posts: serialize_posts(upload.posts),
      }
    end
  end

  def serialize_posts(posts)
    posts.map do |post|
      {
        id: post.id,
        url: post.url,
        post_number: post.post_number,
        topic_title: post.topic&.title,
        is_pm: post.topic&.private_message?,
      }
    end
  end
end
