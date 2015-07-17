# The superclass from which all the pearl modules will inherit from.
module PearlEngine
  class PearlModule < ActiveRecord::Base
    # This is the name of the json file that defining the conversation tree which this module depends on.
    @@inputFileName = nil


    # This is a hash containing all the data attributes that the module requires to function.
    # Must specify the sampleType and unit for context which is tied to Healthkit data.
    # An example @@contextRequirement for interacting with iOS to get step count context is:
    #     @@ContextRequirements = {
    #     "HKQuantityTypeIdentifierStepCount": {
    #       "sampleType": "HKQuantityTypeIdentifierStepCount",
    #       "unit": "count"
    #       }
    #     }
    @@ContextRequirements = nil


    # The conversationHash instance variable stores a full hash of the conversation tree for this module.
    attr_reader :conversationHash

  
    def getContextRequirements
      return @@ContextRequirements
    end


    def initializeContext
    end


    # Returns a string representation of the start of today's date.
    # For example, if today was January 2nd, 2000, it returns "2000-01-02 00:00:00".
    # FIXME: There could be a slight mismatch of dates since iOS HealthKit data is stored
    # with local time, while this is based off GMT. For example, if local time was 7/1 at 11PM while
    # GMT was 7/2 at 1am, then startOfDay would incorrectly return the start of 7/2 instead of 7/1.
    def startOfDay
      Time.now.beginning_of_day.to_s(:db)
    end

    # Returns a string representation of the end of today's date.
    # For example, if today was January 2nd, 2000, it returns "2000-01-02 23:59:59".
    def endOfDay
      Time.now.end_of_day.to_s(:db)
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


    # Input: a filter string with the format (##VARIABLE1 $$COMPARATOR ##VARIABLE2)
    # Evaluates the filter expression and returns true or false
    def pass_filter?(filter)
      
      # Test data
      @contextDataHash = {
        "exerciseDurationGoal": 1800,
        "exerciseDurationToday": 1610,
        "exerciseDurationAvg": 1500,
        "exerciseDurationAboveAvg": 1700,
        "exerciseDurationBelowAvg": 1300,
        "exerciseDurationOverGoal": 0,
        "exerciseDurationUnderGoal": 190,
        "upperGoalRange": 2000,
        "lowerGoalRange": 1600
      }
      
      comparator = filter.scan(/\${2}\w+/)[0].sub(/../,"")
      variables = filter.scan(/\#{2}\w+/)
      var1 = variables[0].sub(/../,"")
      var1 = @contextDataHash.with_indifferent_access[var1]
      var2 = variables[1].sub(/../,"")
      var2 = @contextDataHash.with_indifferent_access[var2]
      if comparator == "between"
        var3 = variables[2].sub(/../,"")
        var3 = @contextDataHash.with_indifferent_access[var3]
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
        return hours.to_s + " hours and " + self.timeWithUnit(seconds)
      elsif seconds == 3600
        return "1 hour"
      elsif seconds > 60
        minutes = (seconds/60).floor
        seconds = seconds%60
        return minutes.to_s + " minutes and " + self.timeWithUnit(seconds)
      elsif seconds == 60
        return "1 minute"
      elsif seconds > 1
        return seconds.to_s + " seconds"
      elsif seconds == 1
        return "1 second"
      else
        return ""
      end
    end


    # Given a valid inputFileName, this creates a conversation hash and intantiates it as the conversationHash
    # instance variable.
    def initializeConversation
      spec = Bundler.load.specs.find{|s| s.name == 'pearl_engine' }
      raise GemNotFound, "Could not find pearl_engine in the current bundle." unless spec
      pearlEngineRootPath = spec.full_gem_path
      filePath = File.join(pearlEngineRootPath, 'lib', 'pearl_engine', 'json_files', @@inputFileName)
      conversation = File.read(filePath)
      conversation_hash = JSON.parse(conversation)
      @conversationHash = conversation_hash
    end


    # Takes as a parameter the ID of a conversation node. Replaces variables in the conversation node with their
    # respective values stored in the contextDataHash. Returns the conversation hash at that conversation node.
    def converse(cardID = "root")

    # Test data
    # @contextDataHashWithUnits = {
    #     "exerciseDurationGoal": self.timeWithUnit(1800),
    #     "exerciseDurationToday": self.timeWithUnit(1610),
    #     "exerciseDurationAvg": self.timeWithUnit(1500),
    #     "exerciseDurationAboveAvg": self.timeWithUnit(1700),
    #     "exerciseDurationBelowAvg": self.timeWithUnit(1200),
    #     "exerciseDurationOverGoal": self.timeWithUnit(0),
    #     "exerciseDurationUnderGoal": self.timeWithUnit(190),
    #     "upperGoalRange": self.timeWithUnit(2000),
    #     "lowerGoalRange": self.timeWithUnit(1600)
    #   }

      card = @conversationHash[cardID]
      if not card["messages"].nil?
        if card["messages"].class == Array
          card["messages"].map! {|message| message % @contextDataHashWithUnits}
        else
          card["messages"] =  card["messages"] % @contextDataHashWithUnits
        end
      end

      return card
    end

  end
end
