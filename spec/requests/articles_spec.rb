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

   fit "レコードを作成する" do
    expect { subject }.to change {Article.where(user_id: current_user.id).count }.by(1)
    res = JSON.parse(response.body)
    expect(res["title"]).to eq params[:article][:title]
    expect(res["body"]).to eq params[:article][:body]
    expect(response).to have_http_status(200)
   end
  end
 end
end
