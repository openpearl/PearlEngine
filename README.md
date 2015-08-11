# PearlEngine
A rails engine which handles Pearl conversation logic.


## Installation
Add this gem to the Gemfile of the API:

```ruby
gem 'pearl_engine', :git => 'git://github.com/openpearl/PearlEngine.git', :branch => 'master' 
```

Then, install the engine by calling:

```console
bundle install 
```
 
## For Developers:
### Creating New Plugins
Plugins are the "brains" of a Pearl conversation, and typically address a specific user concern (for example an eat plugin might focus on a user's eating habits). They are composed of two parts - a plugin model and a conversation tree json file associated with the plugin. When creating a new plugin, you need to create both parts.


#### Creating the Conversation Tree
[Use the pearl storyboarding tool](https://github.com/openpearl/PearlStoryboard) to help you easily create the conversation tree in json format.


#### Creating the Plugin
To make the process of creating a new plugin easier, a custom pearl plugin generator is included with the engine. 
Let's say you wanted to make a new `Foo plugin`. To start, make sure you have already cloned PearlEngine. 
Then, open up a terminal window and `cd` into the root directory of PearlEngine. Finally, simply run:
###### Example: creating a Foo plugin
```console
rails generate pearl_plugin foo
```
This will generate both the ruby file for the plugin as well as its associated json file:


```ruby
# app/models/pearl_engine/plugins/foo_plugin.rb

module PearlEngine
  module Plugins
    class FooPlugin < PearlEngine::PearlPlugin
    ...
    end
  end
end
```
```ruby
# lib/pearl_engine/json_files/foo.json
```
Simply paste the json storyboard created using the [pearl storyboarding tool](https://github.com/openpearl/PearlStoryboard) into `lib/pearl_engine/json_files/foo.json`, and then flesh out the method stubs in `app/models/pearl_engine/plugins/foo_plugin.rb` as needed.
