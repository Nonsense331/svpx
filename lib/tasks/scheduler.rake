desc "This task is called by the Heroku scheduler add-on"
task :update_activities => :environment do
  puts "Updating activities..."
  User.update_activities
  puts "done."
  puts "Deleting old videos..."
  Video.where(watched: true).where("created_at < ?", Time.now - 1.month).destroy_all
  puts "done."
end