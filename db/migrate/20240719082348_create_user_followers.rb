class CreateUserFollowers < ActiveRecord::Migration[7.1]
  def change
    create_table :user_followers do |t|
      t.integer :follower_id
      t.integer :followee_id

      t.timestamps
    end
  end
end
