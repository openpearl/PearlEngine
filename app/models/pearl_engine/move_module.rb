module PearlEngine
  class MoveModule < PearlModule
    attr_accessor :conversation
    
    # def initialize()
      # @conversation = "hi"
    # end
    
    
    def loadConversation
      inputFileName = 'move.json'
      
      spec = Bundler.load.specs.find{|s| s.name == 'pearl_engine' }
      raise GemNotFound, "Could not find pearl_engine in the current bundle." unless spec
      pearlEngineRootPath = spec.full_gem_path 
      filePath = File.join(pearlEngineRootPath, 'lib', 'pearl_engine', 'json_files', inputFileName)
      
      conversation = File.read(filePath)
      conversation_hash = JSON.parse(conversation)
      return conversation_hash
    end
    # a = PearlEngine::MoveModule.new
    
  end
end
