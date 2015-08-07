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
1. [Use this tool](https://github.com/openpearl/PearlTool-LogicGenerator) to help you easily create the conversation tree in json format.
2. Place the completed json file in the `lib/pearl_engine/json_files` directory.


#### Creating the Plugin
Start by creating a new ruby file in the `app/models/pearl_engine/plugins` directory. Make sure it inherits from the PearlPlugin class. For example, if you wanted to create a "Foo" plugin, the corresponding ruby file would looke like:

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
Be sure to define `INPUT_FILE_NAME`(name of the associated conversation tree json file), `STORYBOARD`(the conversation storyboard which is loaded from `INPUT_FILE_NAME`), `CONTEXT_REQUIREMENTS`(the context data that this plugin will require), and the `initializeContext` method (directions for calculating any variables which you defined in the conversation storyboard).
