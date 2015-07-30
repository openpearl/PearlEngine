# The superclass from which all the pearl plugins will inherit from.
module PearlEngine
  class PearlPlugin
    # Right now it is just picking a random plugin. 
    # TODO: Make this smarter.
    def self.choosePlugIn(userID)
      if Rails.cache.read("#{userID}/plugin").nil?
        pluginsList = PearlEngine::PearlPlugin.descendants
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
    # Caches that data for quick access. 
    def initializeContext(contextData, userID)
    end


    def getContextRequirements
      return self.class::CONTEXT_REQUIREMENTS
    end


    # Returns in Unix time the start of today's date.
    # For example, if today was January 1st, 2000 at 12AM, it returns 946702800.
    # FIXME: There could be a slight mismatch of dates since iOS HealthKit data is stored
    # with local time, while this is based off GMT. For example, if local time was 7/1 at 11PM while
    # GMT was 7/2 at 1am, then startOfDay would incorrectly return the start of 7/2 instead of 7/1.
    def startOfDay
      Time.now.beginning_of_day.to_i
    end

    # Returns in Unix time the end of today's date.
    # For example, if today was January 1st, 2000 at 12AM, it returns 946789199.
    def endOfDay
      Time.now.end_of_day.to_i
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


    # Input: a filter string with the format (##VARIABLE1 $$COMPARATOR ##VARIABLE2 ##VARIABLE3)
    # Evaluates the filter expression and returns true or false
    def pass_filter?(filter, userID)
      contextDataHash = Rails.cache.read("#{userID}/contextDataHash")
      comparator = filter.scan(/\${2}\w+/)[0].sub(/../,"")
      variables = filter.scan(/\#{2}\w+/)
      var1 = variables[0].sub(/../,"")
      var1 = contextDataHash.with_indifferent_access[var1]
      var2 = variables[1].sub(/../,"")
      var2 = contextDataHash.with_indifferent_access[var2]
      if comparator == "between"
        var3 = variables[2].sub(/../,"")
        var3 = contextDataHash.with_indifferent_access[var3]
        send(comparator, var1, var2, var3)
      else
        send(comparator, var1, var2)
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
    # respective values stored in the contextDataHash. Returns the a hash of information for that storyboard card.
    def populateCardData(cardID, userID)
      contextDataHashWithUnits = Rails.cache.read("#{userID}/contextDataHashWithUnits")
      card = self.class::STORYBOARD[cardID].deep_dup
      if not card["messages"].nil?
        if card["messages"].class == Array
          card["messages"].map! {|message| message % contextDataHashWithUnits}
        else
          card["messages"] =  card["messages"] % contextDataHashWithUnits
        end
      end

      return card
    end


    # Gets the card at the requested cardID in the storyboard with all context data populated
    def getCard(cardID = "root", userID)
      if Rails.cache.read("#{userID}/contextDataHash").nil?
        return nil
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
            if self.pass_filter?(childCard["filters"], userID)
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

        if childCard["messages"].class == Array
          numberOfMessages = childCard["messages"].length
          randomMessage = Random.rand(numberOfMessages)
          childCard["messages"] = childCard["messages"][randomMessage]
        end

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
        # Clear the cached data since we are at a leaf node of the storyboard,
        # which means conversation has reached the end.
        Rails.cache.delete("#{userID}/plugin")
        Rails.cache.delete("#{userID}/contextDataHash")
        Rails.cache.delete("#{userID}/contextDataHashWithUnits")
        
        return nil
      end
    end

    private


    # Given a valid inputFileName, this loads the complete storyboard as a json hash
    def self.initializeStoryboard(fileName)
      spec = Bundler.load.specs.find{|s| s.name == 'pearl_engine' }
      raise GemNotFound, "Could not find pearl_engine in the current bundle." unless spec
      pearlEngineRootPath = spec.full_gem_path
      filePath = File.join(pearlEngineRootPath, 'lib', 'pearl_engine', 'json_files', fileName)
      conversationTree = File.read(filePath)
      storyboard = JSON.parse(conversationTree)
      return storyboard
    end
  end
end
