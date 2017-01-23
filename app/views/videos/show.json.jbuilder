json.success true
json.video do
  json.extract! @video, :id, :youtube_id, :love, :plays, :title, :published_at_display
  json.channel_title @video.channel.title
end
