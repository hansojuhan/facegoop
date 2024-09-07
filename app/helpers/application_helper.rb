module ApplicationHelper

  def show_user_profile_image(profile)
    # If uploaded image exists, show that
    if profile.profile_image.present?
      image_tag(profile.profile_image, class:'h-full object-cover')
    # If Google image exists, show that
    elsif profile.avatar_url.present?
      image_tag(profile.avatar_url, class:'h-full')
    # Otherwise show the default svg
    else
      raw <<-SVG
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-3/4 text-slate-500">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"></path>
      </svg>
      SVG
    end
  end
end
