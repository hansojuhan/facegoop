# Facegoop

Goal: social media site (url: https://www.theodinproject.com/lessons/ruby-on-rails-rails-final-project)

User should be able to:

- [ ] Sign in to see anything except the sign in page.

- [ ] Send follow requests and accept follow requests from other users.

- [ ] Create posts (including text only).

- [ ] Like posts

- [ ] Comment on posts

## Other requirements

- [ ] Post should display the post content, author, comments, likes.

- [ ] There should be an index page for posts, showing all posts from current user and users they are following.

- [ ] User can create a profile with a profile picture (fetch profile from OmniAuth or Gravatar). Profile contains profile information, photo, posts.

- [ ] Index page for users, showing all users and buttons to send follow requests (if not already following or have a pending request).

- [ ] Welcome mail is sent to a new signed up user.

- [ ] Add basic tests using RSpec.

## Extra requirements

- [ ] Add images to posts.

- [ ] Allow uploading a profile photo.

- [ ] Make your post able to be either a text OR a photo by using a polymorphic association.

---

## Notes

First goal is releasing v0.1.0 of the app, which should include the first 3 requirements:

1. Sign in to see anything except the sign in page.

2. Send follow requests and accept follow requests from other users.

3. Create posts (including text only).

### 1. Users with Devise

Set up users with Devise, so user could register the account and log in. This is straight forward with devise by 1) adding the gem to Gemfile, 2) running `bundle install` and 3) running the generator `rails generate devise:install` (down the line will also run rails g devise:views in order to be able to style the devise views).

Then generate a User (`rails generate devise User`), and migrate db.

### 2. Post model and associations with User

Generate the posts controller in order to have an index page for viewing posts. Generate post model with text and author only.

> `bin/rails g model Post content author:references`

NB: 'author' is actually the User model, so this needs to be specified:

- In the migration: `t.references :author, null: false, foreign_key: { to_table: :users }`

- In the User model: `has_many :posts, foreign_key: 'author_id'`

- In the Post model: `belongs_to :author, class_name: 'User', foreign_key: 'author_id'`

After this is done, we can verify that associations are working by opening the bin/rails console and trying the following:

```rb
u = User.create!(email: "test@test.com", password: "12341234")

p = Post.create!(content: "Test post", author: u)

puts p.author.email # Should output "test@test.com"
puts u.posts.first.content # Should output "Test post"

irb(main):008> puts p.author.email
test@test.com
irb(main):011> u.posts.first.content
  Post Load (0.3ms)  SELECT "posts".* FROM "posts" WHERE "posts"."author_id" = $1 ORDER BY "posts"."id" ASC LIMIT $2  [["author_id", 1], ["LIMIT", 1]]
=> "Test post"
```

### 3. Get started with testing with RSpec

At this point I'm adding RSpec in order to get started with tests already in the beginning. This way, each new feature can simply be implemented with tests, ensuring nothing else is breaking.

