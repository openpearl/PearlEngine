module PearlEngine
  module Plugins
    class AuthenticatePlugin < PearlEngine::PearlPlugin
      # Instructions for handling user input during the conversation, if any.
      def handleUserInput(cardBody, userID)
        cardBody.keys.each do |key|
          case key
          when "email"
            user = ::User.find_by("email": cardBody[key])
            if not user.nil?
              emailUnique = false
            else
              emailUnique = true
            end
            self.cacheToPluginData({"emailUnique": emailUnique}, userID)

            emailMatchesRegex = cardBody[key] =~ VALID_EMAIL_REGEX
            if emailMatchesRegex.nil?
              emailValid = false
            else
              emailValid = true
            end
            self.cacheToPluginData({"emailValid": emailValid}, userID)
          when "password"
            passwordLength = cardBody[key].length
            passwordValid = passwordLength >= 8
            self.cacheToPluginData({"passwordValid": passwordValid}, userID)

            email = Rails.cache.read("#{userID}/pluginDataHash")[:email]
            user = ::User.find_by("email": email)
            if not user.nil? and user.valid_password?(cardBody[key])
              signInValid = true
            else
              signInValid = false
            end
            self.cacheToPluginData({"signInValid": signInValid}, userID)
          when "password_confirmation"
            password = Rails.cache.read("#{userID}/pluginDataHash")[:password]
            passwordConfirmed = cardBody[key] == password
            self.cacheToPluginData({"passwordConfirmed": passwordConfirmed}, userID)
          end
        end
      end


      # Overwrite the endConversation method in order to give the client a hash of data that they can use
      # to sign in, sign up, etc.
      def endConversation(userID)
        authenticate_hash = {
          "action": "",
          "parameters": {
            "confirm_success_url": "https://openpearl.org"
          }
        }.with_indifferent_access

        pluginDataHash = Rails.cache.read("#{userID}/pluginDataHash").with_indifferent_access

        SENSITIVE_DATA.each do |key|
          if not pluginDataHash[key].nil?
            authenticate_hash["parameters"][key] = pluginDataHash[key]
          end
        end

        name_present = !authenticate_hash["parameters"]["name"].nil?
        email_present = !authenticate_hash["parameters"]["email"].nil?
        password_present = !authenticate_hash["parameters"]["password"].nil?
        password_confirm_present = !authenticate_hash["parameters"]["password_confirmation"].nil?

        if name_present and email_present and password_present and password_confirm_present
          authenticate_hash["action"] = "register"
        elsif email_present and not password_present
          authenticate_hash["action"] = "forget_password"
        elsif not email_present and password_present and password_confirm_present
          authenticate_hash["action"] = "change_password"
        elsif email_present and password_present
          authenticate_hash["action"] = "sign_in"
        else
          authenticate_hash["action"] = "no_action_found"
        end

        self.clearUserCache(userID)
        return authenticate_hash
      end


      # ALL plugins must AT THE MINIMUM define the following 3 constants: 
      # INPUT_FILE_NAME, STORYBOARD, and CONTEXT_REQUIREMENTS
      private

      # This is the name of the json file that defines the conversation tree which this plugin depends on.
      INPUT_FILE_NAME = "authenticate.json"

      # This is the complete storyboard of the conversation
      STORYBOARD = self.initializeStoryboard(INPUT_FILE_NAME)

      # This is a hash containing all the data attributes that the plugin requires to function.
      CONTEXT_REQUIREMENTS = {}

      SENSITIVE_DATA = ["name", "email", "password", "password_confirmation"]

      # Should be the same as the email regex defined in the User model
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    end
  end
end
