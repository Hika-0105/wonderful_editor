require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なパラメータが送信された時" do
      let(:params) { attributes_for(:user) }
      fit "ユーザーが新規登録される" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "ヘッダー情報が受け取れる" do
        subject
        res = response.header
        expect(res["access-token"]).to be_present
        expect(res["client"]).to be_present
        expect(res["uid"]).to be_present
        expect(res["expiry"]).to be_present
        expect(res["token-type"]).to be_present
      end
    end

    context "name が存在しないとき" do
      let(:params) { attributes_for(:user, name: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["name"]).to include "can't be blank"
      end
    end

    context "password が存在しないとき" do
      let(:params) { attributes_for(:user, password: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["password"]).to include "can't be blank"
      end
    end

    context "email が存在しないとき" do
      let(:params) { attributes_for(:user, email: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["email"]).to include "can't be blank"
      end
    end
  end
end
