class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :article_likes, dependent: :destroy
  enum status: { draft: 0, published: 1 }
  validates :title, presence: true
end
