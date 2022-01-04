require "rails_helper"

RSpec.describe Article, type: :model do
  context "タイトルと本文が存在する時" do
    let(:article) { build(:article) }

    it "下書きを作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "タイトルが存在しない時" do
    let(:article) { build(:article, title: nil) }
    it "エラーが起きる" do
      expect(article).not_to be_valid
    end
  end

  context "status = draftの時" do
    let(:article) { build(:article, :draft) }

    it "下書きを作成する" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "status = publishedの時" do
    let(:article) { build(:article, :published) }

    it "公開記事を作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "published"
    end
  end
end
