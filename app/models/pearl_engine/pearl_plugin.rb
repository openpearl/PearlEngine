# The superclass from which all the pearl plugins will inherit from.
module PearlEngine
  class PearlPlugin
    SECONDS_IN_DAY = 24*60*60

    # Right now it is just picking a random plugin.
    # TODO: Make this smarter.
    def self.choosePlugIn(userID)
      # If user id is is a base64 string, then we know that it is a guest user,
      # and so we return the authenticate plugin for the guest to login/register/etc.
      if userID.is_a? String
        return PearlEngine::Plugins::AuthenticatePlugin.new
      end

      if Rails.cache.read("#{userID}/plugin").nil?
        # Remove authenticate plugin from the list of plugins, since it should only run if user is not logged in.
        pluginsList = PearlEngine::PearlPlugin.descendants - [PearlEngine::Plugins::AuthenticatePlugin]
        randomPlugin = pluginsList[Random.rand(pluginsList.length)]
        randomPluginName = randomPlugin.to_s
        Rails.cache.write("#{userID}/plugin", randomPluginName, expires_in: 1.hour)
        return randomPlugin.new
      else
        pluginName = Rails.cache.read("#{userID}/plugin")
        return pluginName.constantize.new
      end
    end


    # To be implemented by subclasses of PearlPlugin.
    # Takes context data and performs calculations to get the data to be used in the conversation.
    def calculatePluginData(contextData)
    end


    # To be implemented by subclasses of PearlPlugin.
    # Generates and returns a hash of the plugin data to be used during a conversation.
    def getPluginDataHash
    end


    # To be implemented by subclasses of PearlPlugin.
    # Very similar to getPluginDataHash, with the different being that the data are now strings
    # formatted with their units(IE "10 seconds" instead of just 10).
    def getPluginDataHashWithUnits
    end

    # To be implemented by subclasses of PearlPlugin.
    # Instructions for processing user input, if any.
    def handleUserInput(cardBody, userID)
    end

    # Caches the plugin data. ran at the start of a conversation
    def cachePluginData(userID, pluginDataHash, pluginDataHashWithUnits)
      Rails.cache.write("#{userID}/pluginDataHash", pluginDataHash,  expires_in: 1.hour)
      Rails.cache.write("#{userID}/pluginDataHashWithUnits", pluginDataHashWithUnits,  expires_in: 1.hour)
      return "success"
    end

    # Adds to the plugin data hash. May be called after the start of a conversation
    def cacheToPluginData(cardBody, userID)
      pluginDataHash = Rails.cache.read("#{userID}/pluginDataHash")
      if pluginDataHash.nil?
        pluginDataHash = {}
      end
      # Ensure hash keys are symbols
      cardBody = JSON.parse(cardBody.to_json,:symbolize_names => true)
      pluginDataHash.merge!(cardBody)
      Rails.cache.write("#{userID}/pluginDataHash", pluginDataHash,  expires_in: 1.hour)
    end


    def initializeContext(contextData, userID)
      self.calculatePluginData(contextData)
      pluginDataHash = self.getPluginDataHash
      pluginDataHashWithUnits = self.getPluginDataHashWithUnits
      self.cachePluginData(userID, pluginDataHash, pluginDataHashWithUnits)
    end


    def getContextRequirements
      contextRequirements = self.class::CONTEXT_REQUIREMENTS
      return contextRequirements.with_indifferent_access
    end


<<<<<<< HEAD
    # Returns in Unix time the start of today's date.
    # For example, if today was January 1st, 2000 at 12AM, it returns 946702800.
=======
    # Returns a unix time representing the start of the day at 12:00AM.
>>>>>>> release-1.3.0
    # FIXME: There could be a slight mismatch of dates since iOS HealthKit data is stored
    # with local time, while this is based off GMT. For example, if local time was 7/1 at 11PM while
    # GMT was 7/2 at 1am, then startOfDay would incorrectly return the start of 7/2 instead of 7/1.
    def startOfDay
<<<<<<< HEAD
      Time.now.beginning_of_day.to_i
    end

    # Returns in Unix time the end of today's date.
    # For example, if today was January 1st, 2000 at 12AM, it returns 946789199.
    def endOfDay
      Time.now.end_of_day.to_i
=======
      Time.now.getutc.beginning_of_day.to_i
    end

    # Returns a unix time representing the end of the day at 11:59PM.
    def endOfDay
      Time.now.getutc.end_of_day.to_i
>>>>>>> release-1.3.0
    end


    def greaterThan(a,b)
      a > b
    end

    def lessThan(a,b)
      a < b
    end

    def between(a,b,c)
      a.between?(b,c)
    end

    def equals(a,b)
      a == b
    end


    # Input: a filter array with each filter in the format "##VARIABLE1 $$COMPARATOR ##VARIABLE2 ##VARIABLE3"
    # Evaluates the filter expressions and returns true if all pass, otherwise false
    def pass_filters?(filterArray, userID)
      pluginDataHash = Rails.cache.read("#{userID}/pluginDataHash").with_indifferent_access
      passAllFilters = true

      filterArray.each do |filter|
        comparator = filter.scan(/\${2}\w+/)[0].sub(/../,"")
        variables = filter.scan(/\#{2}\w+/)
        var1 = variables[0].sub(/../,"")
        var1 = pluginDataHash[var1]
        var2 = variables[1].sub(/../,"")
        if var2 == "true"
          var2 = true
        elsif var2 == "false"
          var2 = false
        else
          var2 = pluginDataHash[var2]
        end
        if comparator == "between"
          var3 = variables[2].sub(/../,"")
          var3 = pluginDataHash[var3]
          passFilter = send(comparator, var1, var2, var3)
        else
          passFilter = send(comparator, var1, var2)
        end

        if not passFilter
          passAllFilters = false
        end

        return passAllFilters
      end
    end


    # Takes an integer value representing time in seconds, and returns a string with a time and unit format.
    # For example, passing in 9001 will return "2 hours and 30 minutes and 1 second"
    def timeWithUnit(seconds)
      seconds = seconds.to_i
      if seconds > 3600
        hours = (seconds/3600).floor
        seconds = seconds%3600
        if seconds > 0
          return hours.to_s + " hours and " + self.timeWithUnit(seconds)
        else
          return hours.to_s + " hours"
        end
      elsif seconds == 3600
        return "1 hour"
      elsif seconds > 60
        minutes = (seconds/60).floor
        seconds = seconds%60
        if seconds > 0
          return minutes.to_s + " minutes and " + self.timeWithUnit(seconds)
        else
          return minutes.to_s + " minutes"
        end
      elsif seconds == 60
        return "1 minute"
      elsif seconds > 1
        return seconds.to_s + " seconds"
      elsif seconds == 1
        return "1 second"
      else
        return "0 seconds"
      end
    end


    # Takes as a parameter the ID of a storyboard card. Replaces variables in the storyboard card with their
    # respective values stored in the pluginDataHash. Returns the a hash of information for that storyboard card.
    def populateCardData(cardID, userID)
      pluginDataHashWithUnits = Rails.cache.read("#{userID}/pluginDataHashWithUnits")
      pluginDataHash = Rails.cache.read("#{userID}/pluginDataHash")

      # Perform a deep copy so we don't directly alter the card on STORYBOARD
      card = self.class::STORYBOARD[cardID].deep_dup

      # If messages exist, pick a random message
      if not card["cardBody"].nil? and not card["cardBody"]["messages"].nil?
        numberOfMessages = card["cardBody"]["messages"].length
        randomMessage = Random.rand(numberOfMessages)
        begin
          card["cardBody"]["messages"] = [card["cardBody"]["messages"][randomMessage] % pluginDataHashWithUnits]
        rescue
          card["cardBody"]["messages"] = [card["cardBody"]["messages"][randomMessage] % pluginDataHash]
        end
      end
      return card
    end


    # Gets the card at the requested cardID in the storyboard with all context data populated
    def getCard(cardID = "root", userID)
      # Ensures that the context data has already been calculated and cached before starting a conversation,
      # unless the user is a guest user in which case it is not required.
      if Rails.cache.read("#{userID}/pluginDataHash").nil?
        return nil unless userID.is_a? String
      end

      # Gets the card in the storyboard corresponding to the provided cardID
      card = self.class::STORYBOARD[cardID]

      # Checks to see if the card is the last card in the storyboard by checking whether or not
      # it has children. If it does have children, then the conversation continues.
      # If not, then we know that the conversation has come to an end.
      if not card["childrenCardIDs"].nil?

        # Filter out any invalid children
        filteredCardIDs = []
        card["childrenCardIDs"].each do |childCardID|
          childCard = self.class::STORYBOARD[childCardID]
          if not childCard["filters"].nil?
            if self.pass_filters?(childCard["filters"], userID)
              filteredCardIDs.push(childCardID)
            end
          else
            filteredCardIDs.push(childCardID)
          end
        end


        # If there is more than one valid child card after filtering, we choose a card
        # randomly to proceed with in our conversation.
        # We also pick an AI message randomly to add variety to the conversation.
        numberOfchildren = filteredCardIDs.length
        randomIndex = Random.rand(numberOfchildren)
        randomID = filteredCardIDs[randomIndex]
        childCard = self.populateCardData(randomID, userID)


        if not childCard["childrenCardIDs"].nil?
          # List of all the children cards of the chosen child card.
          childrenArray = []
          childCard["childrenCardIDs"].each do |nextCardID|
            nextCard = self.class::STORYBOARD[nextCardID]
            childrenArray.push(nextCard)
          end

          #Save the data about the children conversation nodes in the conversation hash under the
          #key of "childrenCards".
          childCard["childrenCards"] = childrenArray
        end


        #Renders a json of the conversation hash
        return childCard
      else
        self.endConversation(userID)
      end
    end


    # Instructions for wrapping up a conversation. Returns a hashed json response
    def endConversation(userID)
      response_message = {
        status: "error",
        message: 'End of conversation/no plugin loaded!'
      }

      # Clear the cached data since we are at a leaf node of the storyboard,
      # which means conversation has reached the end.
      self.clearUserCache(userID)

      return response_message
    end

    # Clears all cached data for the user
    def clearUserCache(userID)
      Rails.cache.delete("#{userID}")
      Rails.cache.delete("#{userID}/plugin")
      Rails.cache.delete("#{userID}/pluginDataHash")
      Rails.cache.delete("#{userID}/pluginDataHashWithUnits")
    end


    private

    # Given a valid inputFileName, this loads the complete storyboard as a json hash
    def self.initializeStoryboard(fileName)
      spec = Bundler.load.specs.find{|s| s.name == 'pearl_engine' }
      raise GemNotFound, "Could not find pearl_engine in the current bundle." unless spec
      pearlEngineRootPath = spec.full_gem_path
      filePath = File.join(pearlEngineRootPath, 'lib', 'pearl_engine', 'json_files', fileName)
      conversationTree = File.read(filePath)
      storyboard = JSON.parse(conversationTree).with_indifferent_access
      return storyboard
    end
  end
end
