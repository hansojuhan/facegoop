class ChangeFollowerAndFolloweeIdToNullFalse < ActiveRecord::Migration[7.1]
  def change
    change_column_null :user_followers, :follower_id, false
    change_column_null :user_followers, :followee_id, false
  end
end
