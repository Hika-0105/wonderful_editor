require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let!(:article1) { create(:article, :status_published, user: current_user) }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    let!(:article2) { create(:article, user: current_user) }

    it "自分の書いた公開記事一覧を取得する" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 1
      expect(res.map {|d| d["id"] }).to eq [article1.id]
      expect(res[0]["user"]["id"]).to eq current_user.id
      expect(res[0]["user"]["name"]).to eq current_user.name
      expect(res[0]["user"]["email"]).to eq current_user.email
      expect(response).to have_http_status(:ok)
    end
  end
end
