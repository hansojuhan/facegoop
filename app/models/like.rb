class Like < ApplicationRecord
  belongs_to :user

  # Counter cache true will update the likes count on the post whenever likes is created/destroyed
  belongs_to :record, polymorphic: true, counter_cache: true
end
