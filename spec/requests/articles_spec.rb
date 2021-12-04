require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
 describe "GET /articles" do
  subject { get(api_v1_articles_path) }

  let!(:article1) { create(:article, updated_at: 1.days.ago) }
  let!(:article2) { create(:article, updated_at: 2.days.ago) }
  let!(:article3) { create(:article) }
  it "記事の一覧が取得できる" do
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

  context "指定した記事が存在する時" do
  let(:article){create(:article)}
  let(:article_id){article.id}

   it "指定した記事の値を取得できる" do
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


  context "指定した記事が存在しない時" do
  let(:article_id) { 10000000 }

   it "記事が存在しない" do
    expect{ subject }.to raise_error ActiveRecord::RecordNotFound
   end
  end
 end

 describe "POST/articles" do
  before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
  subject { post(api_v1_articles_path, params: params) }
  let(:current_user){create(:user)}

  context "適切なパラメータが送信された時" do
  let(:params){{article: attributes_for(:article)}}

   it "レコードを作成する" do
    expect { subject }.to change {Article.where(user_id: current_user.id).count }.by(1)
    res = JSON.parse(response.body)
    expect(res["title"]).to eq params[:article][:title]
    expect(res["body"]).to eq params[:article][:body]
    expect(response).to have_http_status(200)
   end
  end

  context "不適切なパラメータが送信された時" do
  let(:params){attributes_for(:article)}
   it "エラーする" do
   expect(subject).to raise_error(ActionController::ParameterMissing)
   end
  end
 end

 describe "PATCH /articles/:id" do
  before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
  let(:current_user){create(:user)}
  subject { patch(api_v1_article_path(article_id), params: params) }
  let(:article_id){article.id}
  let(:article){create(:article, user: current_user)}
  let(:params){{article: {title:Faker::Lorem.word, created_at: 1.day.ago}}}

  it "ログインユーザーの記事の修正を行う" do
   expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                         not_change { article.reload.created_at }
  end
 end
end
