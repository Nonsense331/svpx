desc "This task is called by the Heroku scheduler add-on"
task :update_activities => :environment do
  puts "Updating activities..."
  User.update_activities
  puts "done."
end