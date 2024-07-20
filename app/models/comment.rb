class Comment < ApplicationRecord
  # Belongs to a user as the 'author' of the comment
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  belongs_to :post
end
