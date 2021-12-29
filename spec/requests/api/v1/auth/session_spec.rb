require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST/api/v1/auth/sign_in" do
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

  describe "DELETE api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ログアウトに必要な情報を送信した時" do
      let(:user) { create(:user) }
      let(:headers) { user.create_new_auth_token }
      it "ログアウトできる" do
        subject
        expect(user.reload.tokens).to be_blank
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログアウトに誤った情報を送信した時" do
      let(:user) { create(:user) }
      let(:headers) { { "access-token": "a", "token-type": "b", "client": "c", "expiry": "d", "uid": "e" } }
      it "ログアウトできる" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
