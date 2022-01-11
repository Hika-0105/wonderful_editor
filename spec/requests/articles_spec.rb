require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, :published) }
    before { create(:article, :draft) }

    it "公開記事の一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した記事が公開記事の時" do
      let(:article) { create(:article, :published) }
      let(:article_id) { article.id }

      it "指定した記事の値を取得できる" do  # rubocop:disable RSpec/ExampleLength
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "指定した記事が下書きの時" do
      let(:article) { create(:article, :draft) }
      let(:article_id) { article.id }

      it "指定した記事の値を取得できない" do
        expect(subject).to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "指定した記事が存在しない時" do
      let(:article_id) { 10_000_000 }

      it "記事が存在しない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST/articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "記事を公開状態で作成する時" do
      let(:params) { { article: attributes_for(:article, :status_published) } }

      it "公開記事を作成する" do # rubocop:disable RSpec/ExampleLength
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
        expect(res["status"]).to eq "published"
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "記事を下書きで作成する時" do
      let(:params) { { article: attributes_for(:article, :status_draft) } }

      it "下書きを作成する" do # rubocop:disable RSpec/ExampleLength
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
        expect(res["status"]).to eq "draft"
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "不適切なパラメータが送信された時" do
      let(:params) { attributes_for(:article) }
      it "エラーする" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:params) { { article: attributes_for(:article, :status_published) } }
    let(:headers) { current_user.create_new_auth_token }

    context "ログインしているユーザーの記事を修正するとき" do
      let!(:article) { create(:article, :draft, user: current_user) }
      let!(:article_id) { article.id }

      it "ログインユーザーの記事の修正を行う" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              not_change { article.reload.created_at }
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "他のユーザーの記事を更新しようとるすとき" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      let!(:article_id) { article.id }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:article_id) { article.id }
    let!(:article) { create(:article, user: current_user) }
    let(:headers) { current_user.create_new_auth_token }

    it "ログインユーザーの記事の削除を行う" do
      expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(-1)
    end
  end
end
