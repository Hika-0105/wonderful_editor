require "rails_helper"

RSpec.describe Article, type: :model do
  context "タイトルが存在する時" do
    let(:article) { build(:article) }

    it "保存できる" do
      expect(article).to be_valid
    end
  end

  context "タイトルがが存在しない時" do
    let(:article) { build(:article, title: nil) }
    it "エラーが起きる" do
      expect(article).not_to be_valid
    end
  end
end
