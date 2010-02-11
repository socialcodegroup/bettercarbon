namespace :delayed_job do
  desc "Add the default delayed job for twitter"
  task :install_initial => :environment do
    if DelayedJob.count < 1
      Delayed::Job.enqueue(TwitterJob.new, 0, 5.minutes.from_now)
    end
  end
end