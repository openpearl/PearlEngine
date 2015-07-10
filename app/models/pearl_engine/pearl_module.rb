module PearlEngine
  class PearlModule < ActiveRecord::Base
    # This is a hash containing all the data attributes that the module requires to function. 
    # For example, to require the steps data for the user, set this as {"context":["steps"]}.
    @@clientContextRequirements = {}

    # This is the name of the json file that defining the conversation tree which this module depends on.
    @@inputFileName = nil

    # The context instance variable stores a hash of populated context information required by the module, as 
    # defined in @@clientContextRequirements.
    attr_accessor :context

    # The conversationHash instance variable stores a full hash of the conversation tree for this module.
    attr_accessor :conversationHash

    def getClientContextRequirements
      return @@clientContextRequirements
    end

    def setContextData(params)
      @context = params
      return @context
    end

    def initializeContext
    end


    def startOfDay
      DateTime.now.beginning_of_day.to_s(:db)
    end

    def endOfDay
      DateTime.now.end_of_day.to_s(:db)
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

    # Takes as a parameter the ID of a conversation node. Returns the conversation hash at that conversation node.
    def converse(messageId = "root")
      return @conversationHash[messageId]
    end

  end
end
