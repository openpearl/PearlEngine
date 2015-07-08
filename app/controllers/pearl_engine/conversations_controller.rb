require_dependency "pearl_engine/application_controller"

module PearlEngine
  class ConversationsController < ApplicationController
    def converse
      test = PearlModule.new.test
      render json: test
    end
    
  end
end
