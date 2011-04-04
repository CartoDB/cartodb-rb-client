CartoDB Ruby Client
===================

CartoDB ruby client that allows an easy and simple interaction with the CartoDB API.

Requirements
-------------

The only requirement is an Internet connection and a working version of the Ruby language interpreter. Current ruby versions supported are 1.8.7 and 1.9.2

Setup
------

1. Install the client gem:

		gem install cartodb-rb-client

	or if you are using bundler, put this line in your Gemfile:

		gem 'cartodb-rb-client'

2. Log into http://cartodb.com, get your OAUTH credentials and put them in a YAML file:


	*cartodb_config.yml:*

		host: 'https://api.cartodb.com'
		oauth_key: 'YOUR_OAUTH_KEY
		oauth_secret: 'YOUR_OAUTH_SECRET'

3. Setup your CartoDB connection object. To do so, load the YAML file and assign it to a CartoDB::Config object:

		CartoDB::Settings = YAML.load_file(Rails.root.join('config/cartodb_config.yml'))
		CartoDB::Connection = CartoDB::Client::Connection.new

And that's it. Now you should be able to run querys against the CartoDB servers using the CartoDB::Connection object.

