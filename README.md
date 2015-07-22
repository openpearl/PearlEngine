# PearlEngine
A rails engine which handles Pearl conversation logic.


To mount:
1) Add the gem to the Gemfile of the API:
	gem 'pearl_engine'
	
	*Note: Use this instead for local development of the engine
	gem 'pearl_engine', path: "/Users/shanethomas/Desktop/PearlEngine"

	Then, run bundle to install the gem.


2) Specify in the routes.rb file of the API: 
	mount PearlEngine::Engine, at: "/pearl"
	
	
3) At the root directory of your API, copy the database migrations from the pearl engine using:
	rake pearl_engine:install:migrations
	

4) At the root directory of your API, create the database tables with:
	rake db:migrate SCOPE=pearl_engine
	
	*Note: To undo all migrations from the pearl engine, use:
	rake db:migrate SCOPE=pearl_engine VERSION=0