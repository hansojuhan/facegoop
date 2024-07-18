require 'rails_helper'

RSpec.describe Post, type: :model do
  # Test association to an author
  it 'belongs to an author' do
    user = User.create!(email: "test@test.com", password: "12341234")
    post = Post.create!(content: "Test post", author: user) 

    expect(post.author).to eq(user)
  end
end
