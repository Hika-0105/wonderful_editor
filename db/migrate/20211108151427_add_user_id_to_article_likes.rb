class AddUserIdToArticleLikes < ActiveRecord::Migration[6.1]
  def change
    add_reference :article_likes, :user, null: false, foreign_key: true
  end
end
