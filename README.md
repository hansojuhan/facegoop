# Facegoop

Goal: social media site (url: https://www.theodinproject.com/lessons/ruby-on-rails-rails-final-project)

User should be able to:

- [x] Sign in to see anything except the sign in page.

- [ ] Send follow requests and accept follow requests from other users.

- [x] Create posts (text only initially).

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

At this point I'm adding RSpec in order to get started with tests already in the beginning. This way, each new feature can simply be implemented with tests, ensuring nothing else is breaking:

1. Add gem to dev/test environments in Gemfile and `bundle install`

2. Run `rails generate rspec:install`

Done. By running `rspec`, tests are now executed. Only that no tests exists.

Let's add some tests for the Post and user models under `spec/models/` by running:

> bin/rails generate rspec:model Customer
> bin/rails generate rspec:model Post

### 4. Sign in to see anything

Add Posts#index as the root and add a before action of authenticate user.

### 5. Create posts (text only initially).

Next step is creating posts - and here it makes sense to immediately add the whole CRUD for posts. To save time, I generated a scaffold for this.

### 6. Send follow requests and accept follow requests from other users.

Next, it should be possible to send and receive follow requests. A user can follow many users and be followed by many other users. First idea is to create a new table 'userfollowers', so users can follow others through this table. Then, it can be set up that a user has 'followers'.

NB: [example of implementation of this feature](https://rmiverson.medium.com/allowing-users-to-follow-users-self-join-tables-in-ruby-on-rails-4595d9fb878e)

> bin/rails g model UserFollower follower_id:integer followee_id:integer
> bin/rails db:migrate

Then, the associations have to be added to the user.rb model that say that:

- User has 'followees' through the followed_users table and the foreign key is 'follower_id'

- User has 'followers' through the followed_users table and the foreign key is 'followee_id'

To test, everything is working, run bin/rails c and type:

```rb
irb(main):002> u = User.find 1
=> #<User id: 1 ...
irb(main):003> u2 = User.find 2
=> #<User id: 2 ...

irb(main):008> u.followers << u2

# At this point we can easily access the followers and followees:
irb(main):009> u.followers
=> [#<User id: 2 ...
irb(main):010> u2.followees
=> [#<User id: 1 ...
```

#### 6.1. Status enum

The request should also have a status of 'pending' or 'accepted':

- 'pending' - the other person has to click 'accept', so that the user would be able to start seeing their posts.

- 'accepted' - follow request accepted, user can see the posts.

- If request is rejected, the record can be deleted.

Since `status` has only 2 possible values, we can use an enum for this.

Then, a users index page needs to be created, displaying all users. There, each person can have a 'follow' button. Clicking creates a UserFollower with status 'pending'. The other person should now have a possibility to click 'accept' to change the status.

Create migration to add column:
> bin/rails g migration AddStatusToUserFollowers status:integer

Add the enum definition to the user_follower.rb model:
> enum status: { pending: 0, accepted: 1 }
