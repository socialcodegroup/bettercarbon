# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_better-carbon_session',
  :secret      => '9c68aa5540666aa35056246864bc5316a36d25c49d840b98a6d628461c452e4ea7bd5e5d087c7a29b7edb626950915207728f26a536578a74726de894cd77dd9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
