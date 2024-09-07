# Facegoop

Goal: social media site (url: https://www.theodinproject.com/lessons/ruby-on-rails-rails-final-project)

User should be able to:

- [x] Sign in to see anything except the sign in page.

- [x] Send follow requests and accept follow requests from other users.

- [x] Create posts (text only initially).

- [x] Like posts

- [x] Comment on posts

## Other requirements

- [x] Post should display the post content, author, comments, likes.

- [x] There should be an index page for posts, showing all posts from current user and users they are following.

- [x] User can create a profile with a profile picture (fetch profile from OmniAuth or Gravatar). Profile contains profile information, photo, posts.

- [x] Index page for users, showing all users and buttons to send follow requests (if not already following or have a pending request).

- [x] Welcome mail is sent to a new signed up user.

- [ ] Add basic tests using RSpec.

## Extra requirements

- [x] Add images to posts.

- [x] Allow uploading a profile photo.

- [ ] Make your post able to be either a text OR a photo by using a polymorphic association.

## Known bugs / improvement points

- [] With OAuth, it asks for app permissions every time, even if user is already signed up.

- [] With OAuth, it fetches image only during signup, so if it changes/is broken, it won't refetch.
