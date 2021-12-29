require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST/sessions" do
    subject { post(api_v1_user_session_path, params: params) }

    let(:user) { create(:user) }
    let(:params) { attributes_for(:user, email: user.email, password: user.password) }
    context "登録されているユーザーの情報が送信された時" do
      it "ログインできる" do
        subject
        res = response.header
        expect(response).to have_http_status(:ok)
        expect(res["access-token"]).to be_present
        expect(res["client"]).to be_present
        expect(res["uid"]).to be_present
      end
    end

    context "メールアドレスが一致しない時" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "aaa", password: user.password) }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end

    context "パスワードが一致しない時" do
      let(:params) { attributes_for(:user, email: user.email, password: "bbbbbbbb") }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end
  end
end
