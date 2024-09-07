class RemoveFullnameAvatarurlFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :full_name, :string
    remove_column :users, :avatar_url, :string

    add_column :profiles, :full_name, :string
    add_column :profiles, :avatar_url, :string
  end
end
