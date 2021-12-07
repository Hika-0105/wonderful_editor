class AddUserIdToArticles < ActiveRecord::Migration[6.1]
  def change
    add_reference :articles, :user, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
