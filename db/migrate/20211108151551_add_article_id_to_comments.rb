class AddArticleIdToComments < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :article, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end