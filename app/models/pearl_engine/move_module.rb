module PearlEngine
  class MoveModule < PearlModule
    # This is a hash containing all the data attributes that the module requires to function. 
    # For example, to require the steps data for the user, set this as {"context":["steps"]}.
    @@clientContextRequirements = {"context":["steps"]}
    
    # This is the name of the json file that defining the conversation tree which this module depends on.
    @@inputFileName = "move.json"
  
    # The average number of daily steps walked for the logged-in user
    attr_accessor :stepsAvg

    # The number of steps walked today
    attr_accessor :stepsToday

    # The user's target exercise duration for a day
    attr_accessor :exerciseMinuteGoal

    # The number of minutes the user has exercised above his/her daily average. 0 if not above the average.
    attr_accessor :minutesAvgAbove

    # The number of minutes the user has exercised below his/her daily average. 0 if not below the average.
    attr_accessor :minutesAvgBelow

    # The number of minutes the user has currently exercised today.
    attr_accessor :minutesExercised

    # The number of minutes the user has exercised above his/her goal. 0 if not above the goal.
    attr_accessor :minutesMoreExercised
    
    # The number of minutes the user has exercised below his/her goal. 0 if not below the goal.
    attr_accessor :minutesRemaining


    def calcStepsAvg
      @stepsAvg = 0

      @context["steps"].each do |steps|
        stepInteger = steps["quantity"].to_i
        @stepsAvg += stepInteger
      end 

      @stepsAvg = @stepsAvg/2
      return @stepsAvg
    end


    def calcStepsToday
      @stepsToday = 0

      @context["steps"].each do |steps|
        if steps["startDate"] >= self.startOfDay  && steps["endDate"] <= self.endOfDay
          stepInteger = steps["quantity"].to_i
          @stepsToday += stepInteger
        end
      end 

      return @stepsToday
    end


    def calcMinutesExercised
      @minutesExercised = @stepsToday/120    
    end


    def calcExerciseMinuteGoal
      @exerciseMinuteGoal = 30
    end


    def calcMinutesAvgAbove
      if @minutesExercised > @stepsAvg/120
        @minutesAvgAbove = @minutesExercised - @stepsAvg/120
      else
        @minutesAvgAbove = 0 
      end
    end


    def calcMinutesAvgBelow
      if @minutesExercised < @stepsAvg/120
        @minutesAvgBelow = @stepsAvg/120 - @minutesExercised 
      else
        @minutesAvgBelow = 0 
      end
    end


    def calcMinutesMoreExercised
      if @minutesExercised > @exerciseMinuteGoal
        @minutesMoreExercised = @minutesExercised - @exerciseMinuteGoal
      else
        @minutesMoreExercised = 0 
      end

    end


    def calcMinutesRemaining
      if @minutesExercised < @exerciseMinuteGoal
        @minutesRemaining = @exerciseMinuteGoal - @minutesExercised 
      else
        @minutesRemaining = 0 
      end
    end


    # Calculates and instantiates all the instance variables. Returns a hash of the intance variable data.
    def initializeContext
      @stepsAvg = self.calcStepsAvg
      @stepsToday = self.calcStepsToday
      @minutesExercised = self.calcMinutesExercised
      @exerciseMinuteGoal = self.calcExerciseMinuteGoal
      @minutesAvgAbove = self.calcMinutesAvgAbove
      @minutesAvgBelow = self.calcMinutesAvgBelow
      @minutesMoreExercised = self.calcMinutesMoreExercised
      @minutesRemaining = self.calcMinutesRemaining

      hash = {
        "exerciseMinuteGoal": @exerciseMinuteGoal,
        "minutesAvgAbove": @minutesAvgAbove,
        "minutesAvgBelow": @minutesAvgBelow, 
        "minutesExercised": @minutesExercised,
        "minutesMoreExercised": @minutesMoreExercised,
        "minutesRemaining": @minutesRemaining
      }
      return hash
    end


  end
end
