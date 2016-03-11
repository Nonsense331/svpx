json.success true
json.video do
  json.extract! @video, :id, :youtube_id, :love, :plays
  json.channel_title @video.channel.title
end
