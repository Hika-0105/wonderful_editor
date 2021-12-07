require "rails_helper"

RSpec.describe User, type: :model do
  context "必要な情報が存在する時" do
    let(:user) { build(:user) }

    it "ユーザー登録できる" do
      expect(user).to be_valid
    end
  end

  context "nameが存在しない時" do
    let(:user) { build(:user, name: nil) }
    it "エラーが起きる" do
      expect(user).not_to be_valid
    end
  end

  context "emailが存在しない時" do
    let(:user) { build(:user, email: nil) }
    it "エラーが起きる" do
      expect(user).not_to be_valid
    end
  end

  context "passwordが存在しない時" do
    let(:user) { build(:user, password: nil) }
    it "エラーが起きる" do
      expect(user).not_to be_valid
    end
  end
end
