require_dependency "pearl_engine/application_controller"

module PearlEngine
  class ConversationsController < ApplicationController
    before_action :pick_module


    def getContext
      context = @module.getClientContextRequirements
      render json: context
    end

    def setContext
      context = @module.setContextData(context_params)
      data = @module.initializeContext
      render json: data
    end


    def converse
      convHash = @module.converse(context_params["cardID"])
      #Checks to see if the conversation node is a leaf by checking whether or not
      #it has children. If it does have children, then the conversation continues.
      #If not, then we know that the conversation has come to an end.
      if not convHash["childrenCardIDs"][0].nil? 
        #Gets the next conversation node corresponding to the first child of the current node.
        childMessage = @module.converse(convHash["childrenCardIDs"][0])
        
        #Checks who the speaker for the next conversation node is.
        childSpeaker = childMessage["speaker"]
        
        #Gets the number of children conversation nodes belonging to current node
        numberOfchildren = convHash["childrenCardIDs"].count
        
        #Instantiate a children array for keeping track of a node's children.
        childrenArray = Array.new
        
        #If the speaker for the next conversation nodes is the client, then append all the
        #next conversation nodes to an array.
        if childSpeaker=="client"
          numberOfchildren.times do |child|
            cardID = convHash["childrenCardIDs"][child]
            childrenArray.push(@module.converse(cardID))
          end  
        
        #If the speaker for the next conversation node is not the client, then we simply
        #choose a node from the children conversation nodes to proceed with in our conversation.
        #Current, this is done randomly.
        #TODO: Make choosing the next conversation node more intelligent.
        else
          randomNum = Random.rand(numberOfchildren)
          cardID = convHash["childrenCardIDs"][randomNum]
          childrenArray.push(@module.converse(cardID))
        end
        
        #Save the data about the children conversation nodes in the conversation hash under the 
        #key of "childrenCards".
        convHash["childrenCards"] = childrenArray
        
        #Renders a json of the conversation hash 
        render json: convHash
      else
        #Renders a null json since we are at a leaf node and there is no children.
        render json: convHash["childrenCardIDs"][0]
      end

    end




    private

      # Right now it is just pickiing move module by default. TODO: Make this smarter.
      def pick_module
        begin
          @module ||= MoveModule.new
          @module.initializeConversation
        rescue 
          @module = nil
        end
      end


      def context_params
        params.except(:format, :controller, :action)
      end
  end
end
