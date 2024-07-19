class AddStatusToUserFollowers < ActiveRecord::Migration[7.1]
  def change
    add_column :user_followers, :status, :integer, null: false, default: 0
  end
end
