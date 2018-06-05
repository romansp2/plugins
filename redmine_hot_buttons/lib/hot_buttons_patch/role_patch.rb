module HotButtonsPatch
  module RolePatch
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

	  receiver.class_eval do 
	    unloadable
	    has_many :hot_buttons
	  end
	end

	module ClassMethods
	end

	module InstanceMethods
	end
  end
end
