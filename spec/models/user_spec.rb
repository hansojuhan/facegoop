require 'rails_helper'

RSpec.describe User, type: :model do
  it "has many posts" do
    user = User.create!(email: "john@example.com", password: "password")
    post1 = Post.create!(content: "First post", author: user)
    post2 = Post.create!(content: "Second post", author: user)

    expect(user.posts).to include(post1, post2)
  end
end
