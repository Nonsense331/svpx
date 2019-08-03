desc "This task is called by the Heroku scheduler add-on"
task :update_activities => :environment do
  puts "Updating activities..."
  User.update_activities
  puts "done."
  puts "Deleting old videos..."
  videos = Video.order(created_at: :asc).where(watched: true).where("created_at < ?", Time.now - 1.month)
  if videos.count > 5
    videos[0..-4].each(&:destroy!)
  end
  puts "done."
end
