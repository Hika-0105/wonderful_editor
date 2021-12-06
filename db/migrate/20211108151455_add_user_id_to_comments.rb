class AddUserIdToComments < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :user, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
