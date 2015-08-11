module PearlEngine
  module Plugins
    class <%= file_name.camelize + "Plugin" %> < PearlEngine::PearlPlugin


      # handleUserInput() should be defined if you plan to work with open-ended user input in a conversation. 
      # See the authenticate plugin for an example of how it should be implemented.
      #
      # This method can be ignored/removed if the plugin does not work with open-ended user input (i.e. all user
      # input are choices that are pre-defined in the storyboard cards)
      def handleUserInput(cardBody, userID)

      end


      # The following three methods (calculatePluginData, getPluginDataHash, and getPluginDataHashWithUnits)
      # should be defined if you plan to work with variables in the storyboard (such as displaying the current
      # time or the user's name).

      # Calculates and instantiates all the plugin data to be used in the storyboard, if any.
      def calculatePluginData(contextData)

      end

      # Collects the plugin data in a hash for easy caching and substitution in the storyboard, if any.
      def getPluginDataHash
        pluginDataHash = {}
      end

      # Collects the plugin data with units in a hash for easy caching and substitution in the storyboard, if any.
      def getPluginDataHashWithUnits
        pluginDataHashWithUnits = {}
      end



      # If this plugin was created using the pearl_plugin generator, INPUT_FILE_NAME and STORYBOARD do not
      # have to be altered. CONTEXT_REQUIREMENTS may have to be altered depending on the needs of the plugin.
      private

      # This is the name of the json file that defines the conversation tree which this plugin depends on.
      INPUT_FILE_NAME = "<%= file_name + '.json' %>"

      # This is the complete storyboard of the conversation
      STORYBOARD = self.initializeStoryboard(INPUT_FILE_NAME)

      # This is a hash containing all the data attributes stored in TrueVault that the plugin requires to function.
      CONTEXT_REQUIREMENTS = {}
    end
  end
end
