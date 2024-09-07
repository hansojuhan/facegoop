## Notes

First goal is releasing v0.1.0 of the app, which should include the first 3 requirements:

1. Sign in to see anything except the sign in page.

2. Send follow requests and accept follow requests from other users.

3. Create posts (including text only).

## v0.1.0

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

### 5. Create posts (text only initially)

Next step is creating posts - and here it makes sense to immediately add the whole CRUD for posts. To save time, I generated a scaffold for this.

### 6. Send follow requests and accept follow requests from other users

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

#### 6.2. Pages for users

Next, create a users index page for displaying all users.
> bin/rails g controller Users

Next, there should be a button next to each user:

- 'Follow' - to send a follow request

- 'Following' - if a request has been sent and accepted

For this, there should be a way to check if current user is following this user already.
> user.followers.include?(current_user)

The button is added as a partial '_follow_button.html.erb'.

#### 6.3. Show statuses for each user

Using scopes in UserFollower and method in User, it's possible to easily check if user is following/pending a follow/not yet following.

```rb
class UserFollower < ApplicationRecord
  # Scopes to easily access follows by status
  scope :status_pending, -> { where(status: :pending) }
  scope :status_accepted, -> { where(status: :accepted) }
end

class User < ApplicationRecord
  def pending_followees
    followees.merge(UserFollower.status_pending)
  end

  def accepted_followees
    followees.merge(UserFollower.status_accepted)
  end
end
```

#### 6.4. Send and receive follow requests

Last step is sending and accepting follow requests. For this, a new UserFollowersController can be created. This way these can be handled by basic RESTful requests. We only need to create and destroy the follows:
> bin/rails g controller UserFollowersController create destroy

The methods need to get from the view the user to be followed and current user.

Also some changes are needed for the views:

- Turn to 'follow' button into a form.

- Add an 'Unfollow' button, which destroys the follow.

- Add a separate page/list for pending follow requests.

## v0.2.0

### Like posts

Generate model for Likes. In order to eventually apply likes to any model, make it polymorphic:
> rails g model Like user:belongs_to record:belongs_to{polymorphic}

Additionally, let's add a likes counter to the post table. By default this is 0.
> rails g migration AddLikesCountToPosts likes_count:integer

Next step is adding associations.

- Like 'belongs to' record with polymorphic true. By setting `counter_cache: true` the likes_count will be updated automatically in the post table.

- Post 'has many' likes as 'record'

- User 'has many' likes

Each user should have only one like on a post. They can like or unlike the post. For this, we can create a nested controller under posts, so it would have the post id immediately available.

In routes, add like as a singular resource nested in posts.

```rb
# /controllers/posts/likes_controller.rb
class Posts::LikesController < ApplicationController
end

# routes
resources :posts do
  resource :like, module: :posts
end
```

Since liking is basically a state toggle, add just an update method into the controller, which 1) checks if like exists and if not 2) adds a like record (if yes, removes the like record.)

This is accomplished by adding methods into post.rb. #like finds first or creates a record. #unlike destroys all records. This way, duplicates are already taken care of.

Then, a like button partial can be added to the post view that displays like/unlike button based on state and a counter.

A strange thing that happened while testing was this:

1. Click 'like' on a post with counter 0 on the post index page

2. Refresh the page, the post disappears. Check console and `likes_count` indeed was changed to 1.

3. Continue liking all posts.

At this point I realized that the list of all posts keeps reordering itself after liking is done - even though it doesn't seem like it should. Posts are queried as `@posts = Post.all`.

#### Update button with Turbo

Last step is updating the button right after it was clicked. To do this 2 things are necessary:

1. Target on the page. To do this, we can wrap the button in a div tag with a unique dom_id. This can then be targeted by the turbo stream.

```erb
<%# This will generate a string like this: likes_post_1 %>
<%= tag.div id: dom_id(post, :likes) do %>
<% end %>
```

2. Turbo stream response in the controller.

```rb
def update
  ...

  respond_to do |format|
    format.turbo_stream {
      render turbo_stream: turbo_stream.replace(dom_id(@post, :likes), partial: 'posts/likes', locals: { post: @post })
    }
  end
end
```

## v0.3.0

### Comment on posts

Generate Comment model.
> bin/rails g model Comment content:text author:references post:references

In the migration, change:
> t.references :author, null: false, foreign_key: true
> t.references :author, null: false, foreign_key: { to_table: :users }

Add associations:
Comment:
> belongs_to :author, class_name: 'User', foreign_key: 'author_id'
User:
> has_many :comments, foreign_key: 'author_id'
Post:
> has_many :comments

Make sure everything is working by running things in the console like:
> Post.first.comments.first.author
> Comment.first.author

Add a partial for comments in views/comments/_comment.html.erb and render it under the post (show.html.erb)

Generate controller for comments:
> rails g controller Comments

Add a form at the bottom of the comment section as a partial. Add nested resources in posts. Pass the post into render for the :post_id.

Add the Comments#create action to build a new comment in current user's comments. For the params, require comment and permit content. In addition, merge the post_id form the params.

```rb
  def comment_params
    params.require(:comment).permit(:content).merge(post_id: params[:post_id])
  end
```

Now we have a working way to add comments.

#### Performance issue: N+1 queries fetching comments

When we load a post now with multiple comments under it and check the server logs, we can see that a lot of similar requests are being made:
```sh
Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = $1 ORDER BY "comments"."created_at" DESC  [["post_id", 4]]
13:57:35 web.1  |   ↳ app/views/posts/show.html.erb:23
13:57:35 web.1  |   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 2], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 2], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 2], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 4], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 4], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 1], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 3], ["LIMIT", 1]]
13:57:35 web.1  |   ↳ app/views/comments/_comment.html.erb:3
13:57:35 web.1  |   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 1], ["LIMIT", 1]]
```

What is happening here is that we are fetching all of this post's comments from the db. For each comment, we are also displaying its author's email. Since the comment doesn't know anything about the author's email, it needs to go fetch this from the user table every time. This is called an N+1 query (in addition to the 1 query, N queries are done for each entry).

This will cause issues once there are 100s and 1000s of comments - but Rails has a very simple solution for this called eager loading.

Make the following change:
> <%= render @post.comments.order(created_at: :desc) %>
> <%= render @post.comments.includes(:author)order(created_at: :desc) %>

Checking server logs again, now there are only 2 queries, one for post's comments and other to get all needed users as an array:
```sh
14:02:16 web.1  |   Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = $1 ORDER BY "comments"."created_at" DESC  [["post_id", 4]]
14:02:16 web.1  |   ↳ app/views/posts/show.html.erb:23
14:02:16 web.1  |   User Load (0.8ms)  SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3, $4)  [["id", 2], ["id", 4], ["id", 1], ["id", 3]]
14:02:16 web.1  |   ↳ app/views/posts/show.html.erb:23
```

## v0.4.0

This version will include the following functionality:

1. There should be an index page for posts, showing all posts from current user and users they are following.

2. User can create a profile with a profile picture (fetch profile from OmniAuth or Gravatar). Profile contains profile information, photo, posts.

3. Index page for users, showing all users and buttons to send follow requests (if not already following or have a pending request).

4. Welcome mail is sent to a new signed up user.

### Post should display the post content, author, comments, likes.

This one is almost all done already.

- Content is displayed.

- Author's email is displayed.

- Comments section is present.

- Like counter is there.

As an improvement, the following can be done:

- Make the 'Like' button look like a button.

- Display all users who have liked a post.

As a result, post page now has a separate section "Liked by", a separate like counter and a button. This required some changes to how turbo stream updates the page, because suddenly it had to update 3 separate places.

As a solution, created separate partials for each of them and modified the controller to update each:

```rb
format.turbo_stream {
  render turbo_stream: [
    turbo_stream.replace(dom_id(@post, :likes), partial: 'posts/likes', locals: { post: @post }),
    turbo_stream.replace(dom_id(@post), partial: 'posts/likes_count', locals: { post: @post }),
    turbo_stream.replace(dom_id(@post, :liked_by), partial: 'posts/liked_by', locals: { post: @post })
  ]
}
```

### There should be an index page for posts, showing all posts from current user and users they are following.

Index page for posts already exists (the root page), but currently it shows all posts from everybody. So, a change is needed so that it would show posts from 1) user itself and 2) users they are following.

Technically, this would be:

1. Posts by current user

2. Posts by current user's followees with status accepted

This can be achieved by creating a class method in Post, which gets all user IDs of current user's accepted followees, adds in their own and then queries all posts with those author ids:

```rb
  def self.feed_posts(user)
    ids = user.accepted_followees.pluck(:id)
    ids << user.id
    Post.where(author_id: ids)
  end
```

Also, the post index page can be renamed to "Feed".

### Index page for users, showing all users and buttons to send follow requests (if not already following or have a pending request)

Index page for all users exists already. But to make things more simple, let's divide the page into 3 pages:

1. All users

2. Followers (my followers, along with possibility to remove)

3. Following (all users I am following, along with possibility to unfollow)

To get started, create routes for followers and following.
> followers_users_path  GET /users/followers(.:format)  users#followers
> following_users_path  GET /users/following(.:format)  users#following

Then, create the controller actions for these, each of which give either accepted followees or -ers (scopes).

At this point I ran into a small issue: I already have a UserFollowers controller with create and destroy, that can create follow requests and unfollow other users. I also would need to remove my followers. Ideally, I would have two controllers for followers and followees?
At this point I will just add a new method #remove into the existing controller to remove followers and that's it.

Also, looks like duplicate requests can be sent. Fix this with a validation in UserFollower model.
```sh
irb(main):002> user.pending_followees
  User Load (0.4ms)  SELECT "users".* FROM "users" INNER JOIN "user_followers" ON "users"."id" = "user_followers"."followee_id" WHERE "user_followers"."follower_id" = $1 AND "user_followers"."status" = $2 /* loading for pp */ LIMIT $3  [["follower_id", 2], ["status", 0], ["LIMIT", 11]]
=> 
[#<User id: 3, email: "test3@test.com", created_at: "2024-07-19 09:27:15.643418000 +0000", updated_at: "2024-07-19 09:27:15.643418000 +0000">,
 #<User id: 3, email: "test3@test.com", created_at: "2024-07-19 09:27:15.643418000 +0000", updated_at: "2024-07-19 09:27:15.643418000 +0000">,
 #<User id: 3, email: "test3@test.com", created_at: "2024-07-19 09:27:15.643418000 +0000", updated_at: "2024-07-19 09:27:15.643418000 +0000">,
 #<User id: 3, email: "test3@test.com", created_at: "2024-07-19 09:27:15.643418000 +0000", updated_at: "2024-07-19 09:27:15.643418000 +0000">,
 #<User id: 1, email: "test@test.com", created_at: "2024-07-18 08:45:29.351149000 +0000", updated_at: "2024-07-18 08:45:29.351149000 +0000">,
 #<User id: 1, email: "test@test.com", created_at: "2024-07-18 08:45:29.351149000 +0000", updated_at: "2024-07-18 08:45:29.351149000 +0000">,
 #<User id: 3, email: "test3@test.com", created_at: "2024-07-19 09:27:15.643418000 +0000", updated_at: "2024-07-19 09:27:15.643418000 +0000">,
 #<User id: 4, email: "test4@test.com", created_at: "2024-07-19 09:33:04.231189000 +0000", updated_at: "2024-07-19 09:33:04.231189000 +0000">]
irb(main):003> 
```

### User can create a profile with a profile picture (fetch profile from OmniAuth or Gravatar). Profile contains profile information, photo, posts

#### Profile Model

For this, considering creating a separate model for Profile. This way, the extra stuff like profile picture, description, location, title etc. do not need to be included in user, which mainly holds email and password. Each user has one profile.

Some googling confirmed that this is a good idea and it follows what is called the Single Responsibility Principle (meaning one class does one thing).

In order to make sure each user will have a profile, an 'after_create' callback can be used.

#### Add Omniauth with Devise 

Add Omniauth as authentication, in order to be able to fetch the user profile with profile picture.

Exact steps laid out in [this tutorial](https://medium.com/@paulcmorah/mastering-user-authentication-in-rails-7-with-devise-and-omniauth-06b875a14230)

Recap:

1. Add gems for particular Omniauth strategy (Google for example) and CSRF protection

2. For User model, add :omniauthable and the #from_omniauth method that finds or creates user with information received

3. Add the custom sign in Google button into the Devise view (first generate views with 'rails g devise:views' and enable 'config.scoped_views' in Devise conf)

4. Set up the credentials in Google Cloud.

5. Add into Rails credentials Google client ID and secret, add config into Devise.rb

6. Generate also devise controllers ('rails g devise:controllers users') and add routes for each of the controller (registrations, session, omniauth_callbacks)

7. Add to User string columns of 'provider' and 'uid'

Next steps to be done:

- Profile. Name and avatar url should be saved in the profile.

- Editing profile. Create a page for editing profile.

#### User profile

User profile will have all the information about the user that's not related to authentication (that's in the user model):

- Full name

- Bio

- Image

#### Upload profile image

Use built-in ActiveStorage to upload profile images, in dev and test to local disc and in production to Amazon S3.

To set it up:

1. Add to the model `has_one_attached :profile_image`

2. Add to the edit form a `file_field`. Also add an image preview, if `present?`

3. Permit this in the profile strong parameters

To set up a 'Remove' button:

1. Add a new nested resource under profile for the profile image. Add `module: :profiles` to nest route under the model.

2. Create a nested controller `Profiles::ImagesController` and add the destroy action. Add before actions for authenticate and set profile

> NB: module: :profiles and controller name Profiles::ImagesController - profiles in plural.

3. In #destroy, call purge_later on the image, redirect to edit path.

4. In the form, add a link to remove (cannot be a button, since it's already in a form) and add `turbo_method: :delete` to turn it into a delete request.

In order to keep all changes in the edit form, if remove image is pushed, add a turbo_stream response:

1. For the div containing image preview and remove, add a dom id (construct from profile, :profile_image)

2. In the #destroy action, add a turbo stream response to remove that div.

To have `dom_id` in the controller, `include ActionView::RecordIdentifier`

#### Show uploaded profile image

Now, there are 3 options that can be shown as a user's profile image.

1. Default svg file, if there is no image

2. Uploaded image

3. User's Google profile image, if signed in through Google

Logic should be:

1. If Google image exists, show that

2. If Google image exists, but user uploaded their own image, show that instead

3. If none of these exists, show the default svg

To accomplish this, add a helper method.

### Welcome mail is sent to a new signed up user.

A welcome mail can be implemented by doing the following:

## v0.5.0

This version will include:

- [ ] Add images to posts.

- [ ] Make your post able to be either a text OR a photo by using a polymorphic association.

