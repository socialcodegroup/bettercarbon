class CreateContactedTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :contacted_twitter_users do |t|
      t.string  :screen_name
      t.text    :from_tweet_text
      t.timestamps
    end
  end

  def self.down
    drop_table :contacted_twitter_users
  end
end
