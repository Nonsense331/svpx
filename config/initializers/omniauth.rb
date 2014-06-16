Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
    {
      :scope => "email, http://gdata.youtube.com",
      :prompt => "consent",
      :image_aspect_ratio => "square",
      :image_size => 50
    }
end