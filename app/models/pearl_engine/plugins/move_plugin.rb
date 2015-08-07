module PearlEngine
  module Plugins
    class MovePlugin < PearlEngine::PearlPlugin

      # The average number of daily steps walked for the logged-in user
      def calcStepsAvg(contextData)
        stepsTotal = 0
        daysDifference = 1
        if not contextData["HKQuantityTypeIdentifierStepCount"].nil?
          startDate = contextData["HKQuantityTypeIdentifierStepCount"][0]["startDate"]
          endDate = contextData["HKQuantityTypeIdentifierStepCount"][0]["endDate"]
          secondsInDay = 24*60*60
          contextData["HKQuantityTypeIdentifierStepCount"].each do |steps|
            stepsIncrement = steps["quantity"]
            stepsTotal += stepsIncrement
            if steps["startDate"] < startDate
              startDate = steps["startDate"]
            end
            if steps["endDate"] > endDate
              endDate = steps["endDate"]
            end
          end
          daysDifference = 1 + ((Time.at(endDate) - Time.at(startDate))/SECONDS_IN_DAY).floor
        end
        @stepsAvg = stepsTotal/daysDifference
      end

      # The number of steps walked today
      def calcStepsToday(contextData)
        @stepsToday = 0
        if not contextData["HKQuantityTypeIdentifierStepCount"].nil?
          contextData["HKQuantityTypeIdentifierStepCount"].each do |steps|
            if steps["startDate"] >= self.startOfDay && steps["endDate"] <= self.endOfDay
              stepInteger = steps["quantity"]
              @stepsToday += stepInteger
            end
          end
        end
      end


      # The number of minutes the user has currently exercised today.
      # Calculation is based off the assumption that a person typically walks 2 steps in one second
      def calcExerciseDurationToday
        @exerciseDurationToday = @stepsToday/2
      end


      # The average number of minutes the user exercises daiy.
      def calcExerciseDurationAvg
        @exerciseDurationAvg = @stepsAvg/2
      end


      # The user's target exercise duration for a day in seconds. Default of 1800 (30 minutes).
      def calcExerciseDurationGoal
        @exerciseDurationGoal = 1800
      end


      # Returns an exercise duration 10% more than the user's average
      def calcExerciseDurationAboveAvg
        @exerciseDurationAboveAvg = @exerciseDurationAvg * 1.1
      end


      # Returns an exercise duration 10% less than the user's average
      def calcExerciseDurationBelowAvg
        @exerciseDurationBelowAvg = @exerciseDurationAvg * 0.9
      end


      # The number of minutes the user has exercised above his/her goal. 0 if not above the goal.
      def calcExerciseDurationOverGoal
        if @exerciseDurationToday > @exerciseDurationGoal
          @exerciseDurationOverGoal = @exerciseDurationToday - @exerciseDurationGoal
        else
          @exerciseDurationOverGoal = 0
        end
      end


      # The number of minutes the user has exercised below his/her goal. 0 if not below the goal.
      def calcExerciseDurationUnderGoal
        if @exerciseDurationToday < @exerciseDurationGoal
          @exerciseDurationUnderGoal = @exerciseDurationGoal - @exerciseDurationToday
        else
          @exerciseDurationUnderGoal = 0
        end
      end


      # Returns an exercise duration goal 10% more than the user's goal. Anything less than this will be considered
      # average.
      def calcUpperGoalRange
        @upperGoalRange = @exerciseDurationGoal * 1.1
      end


      # Returns an exercise duration goal 10% less than the user's goal. Anything more than this will be considered
      # average.
      def calcLowerGoalRange
        @lowerGoalRange = @exerciseDurationGoal * 0.9
      end


      # Calculates and instantiates all the plugin data.
      def calculatePluginData(contextData)
        self.calcStepsAvg(contextData)
        self.calcStepsToday(contextData)
        self.calcExerciseDurationAvg
        self.calcExerciseDurationToday
        self.calcExerciseDurationGoal
        self.calcExerciseDurationAboveAvg
        self.calcExerciseDurationBelowAvg
        self.calcExerciseDurationOverGoal
        self.calcExerciseDurationUnderGoal
        self.calcUpperGoalRange
        self.calcLowerGoalRange
      end

      # Collects the plugin data in a hash for easy caching and access
      def getPluginDataHash
        pluginDataHash = {
          "exerciseDurationGoal": @exerciseDurationGoal,
          "exerciseDurationToday": @exerciseDurationToday,
          "exerciseDurationAvg": @exerciseDurationAvg,
          "exerciseDurationAboveAvg": @exerciseDurationAboveAvg,
          "exerciseDurationBelowAvg": @exerciseDurationBelowAvg,
          "exerciseDurationOverGoal": @exerciseDurationOverGoal,
          "exerciseDurationUnderGoal": @exerciseDurationUnderGoal,
          "upperGoalRange": @upperGoalRange,
          "lowerGoalRange": @lowerGoalRange
        }
      end


      # Collects the plugin data with units in a hash for easy caching and access
      def getPluginDataHashWithUnits
        pluginDataHashWithUnits = {
          "exerciseDurationGoal": self.timeWithUnit(@exerciseDurationGoal),
          "exerciseDurationToday": self.timeWithUnit(@exerciseDurationToday),
          "exerciseDurationAvg": self.timeWithUnit(@exerciseDurationAvg),
          "exerciseDurationAboveAvg": self.timeWithUnit(@exerciseDurationAboveAvg),
          "exerciseDurationBelowAvg": self.timeWithUnit(@exerciseDurationBelowAvg),
          "exerciseDurationOverGoal": self.timeWithUnit(@exerciseDurationOverGoal),
          "exerciseDurationUnderGoal": self.timeWithUnit(@exerciseDurationUnderGoal),
          "upperGoalRange": self.timeWithUnit(@upperGoalRange),
          "lowerGoalRange": self.timeWithUnit(@lowerGoalRange)
        }
      end


      # ALL plugins must AT THE MINIMUM include the following 3 constants: 
      # INPUT_FILE_NAME, STORYBOARD, and CONTEXT_REQUIREMENTS
      private

      # This is the name of the json file that defines the conversation tree which this plugin depends on.
      INPUT_FILE_NAME = "move.json"

      # This is the complete storyboard of the conversation
      STORYBOARD = self.initializeStoryboard(INPUT_FILE_NAME)

      # This is a hash containing all the data attributes that the plugin requires to function.
      CONTEXT_REQUIREMENTS = {
        "HKQuantityTypeIdentifierStepCount": {
          "sampleType": "HKQuantityTypeIdentifierStepCount",
          "unit": "count"
        }
      }

    end
  end
end
