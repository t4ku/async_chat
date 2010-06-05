# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tascal_session',
  :secret      => '6e1695be74b6eb362eed21ab0e4196b94403f96cc4f17242d038b31d14cad6b61c69380d906945f7f9a77076c2a00905fe477999045ecf9bea6788a48aa60d01'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
