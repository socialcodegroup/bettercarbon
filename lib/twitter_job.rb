require 'twitter'

class TwitterJob# < Struct.new(:text, :emails)
  def perform
    # twitter = Twitter::Base.new('bettercarbon', 'Trouh8az')
    # httpauth = Twitter::HTTPAuth.new('bettercarbon', 'Trouh8az')
    # base = Twitter::Base.new(httpauth)
    # 
    # process_tweet_list(Twitter::Search.new('climate change'), base)
    # process_tweet_list(Twitter::Search.new('#climatechange'), base)
    # process_tweet_list(Twitter::Search.new('#green'), base)
    # process_tweet_list(Twitter::Search.new('carbon footprint'), base)
    # process_tweet_list(Twitter::Search.new('environment'), base)
    # process_tweet_list(Twitter::Search.new('energy'), base)
    # process_tweet_list(Twitter::Search.new('eco'), base)
    
    # twitter.post("@atomicunit Your carbon footprint has been calculated based on your location. View your profile here: http://www.bettercarbon.com/")
    
    # Delayed::Job.enqueue(TwitterJob.new, 0, 3.minutes.from_now)
  end
  
  def process_tweet_list(list, base)
    list.each { |u|
      # if !u.user.location.blank? && ContactedTwitterUser.find(:first, :conditions => ['screen_name = ?', u.user.screen_name]).blank?
      #   base.update("@#{u.user.screen_name} Your carbon footprint has been calculated based on your location. View your profile here: http://bettercarbon.com/profile_lookup/#{u.user.screen_name}")
      #   ContactedTwitterUser.create(:screen_name => u.user.screen_name, :from_tweet_text => u.text)
      # end
      if ContactedTwitterUser.find(:first, :conditions => ['screen_name = ?', u.from_user]).blank?
        base.update("@#{u.from_user} Your carbon footprint has been calculated. View your profile here: http://bettercarbon.com/profile_lookup/#{u.from_user}")
        ContactedTwitterUser.create(:screen_name => u.from_user, :from_tweet_text => u.text)
      end
    }
  end
end