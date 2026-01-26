# frozen_string_literal: true

require "rails_helper"

describe UploadsLibraryController do
  fab!(:admin)
  fab!(:user)
  fab!(:other_user, :user)

  fab!(:upload_1) do
    Fabricate(
      :upload,
      user: user,
      created_at: 2.months.ago,
      original_filename: "old_image.jpg",
      width: 100,
      height: 100,
    )
  end
  fab!(:upload_2) do
    Fabricate(:upload, user: other_user, created_at: 1.month.ago, original_filename: "image.gif")
  end
  fab!(:upload_3) do
    Fabricate(
      :upload,
      user: user,
      created_at: 1.week.ago,
      original_filename: "recent_image.png",
      width: 50,
      height: 50,
    )
  end

  describe "GET #index" do
    it "denies access to anonymous users" do
      get "/admin/uploads.json"
      expect(response.status).to eq(403)
    end

    it "denies access to non-admin users" do
      sign_in(user)
      get "/admin/uploads.json"
      expect(response.status).to eq(403)
    end

    context "when logged in as admin" do
      before { sign_in(admin) }

      it "returns a list of uploads ordered by date (desc)" do
        get "/admin/uploads.json"
        expect(response.status).to eq(200)

        json = response.parsed_body
        ids = json["uploads"].map { |u| u["id"] }

        expect(ids).to include(upload_1.id, upload_2.id, upload_3.id)

        # Ensure correct order (Newest first)
        # upload_3 (1 week ago) > upload_2 (1 month ago) > upload_1 (2 months ago)
        expect(ids.index(upload_3.id)).to be < ids.index(upload_2.id)
        expect(ids.index(upload_2.id)).to be < ids.index(upload_1.id)
      end

      it "includes the correct JSON structure" do
        get "/admin/uploads.json"

        json = response.parsed_body
        target = json["uploads"].find { |u| u["id"] == upload_3.id }

        expect(target["name"]).to eq("recent_image.png")
        expect(target["username"]).to eq(user.username)
        expect(target["is_image"]).to eq(true)
        expect(target["posts"]).to be_an(Array)
      end

      it "filters by username" do
        get "/admin/uploads.json", params: { username: other_user.username }

        json = response.parsed_body
        ids = json["uploads"].map { |u| u["id"] }

        expect(ids).to include(upload_2.id)
        expect(ids).not_to include(upload_1.id) # Belong to 'user', not 'other_user'
      end

      it "filters by date range" do
        from_date = (1.month.ago - 2.days).strftime("%Y-%m-%d")
        to_date = (1.month.ago + 2.days).strftime("%Y-%m-%d")

        get "/admin/uploads.json", params: { from_date: from_date, to_date: to_date }

        json = response.parsed_body
        ids = json["uploads"].map { |u| u["id"] }

        expect(ids).to include(upload_2.id) # Within range
        expect(ids).not_to include(upload_3.id) # Too new (1 week ago)
        expect(ids).not_to include(upload_1.id) # Too old (2 months ago)
      end

      it "handles pagination (limit & offset)" do
        get "/admin/uploads.json"
        full_ids = response.parsed_body["uploads"].map { |u| u["id"] }
        first_item_id = full_ids[0]
        second_item_id = full_ids[1]

        get "/admin/uploads.json", params: { offset: 1 }
        offset_ids = response.parsed_body["uploads"].map { |u| u["id"] }

        expect(offset_ids).not_to include(first_item_id)

        expect(offset_ids.first).to eq(second_item_id)
      end
    end
  end
end
