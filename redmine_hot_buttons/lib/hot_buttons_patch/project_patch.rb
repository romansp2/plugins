module HotButtonsPatch
  module ProjectPatch
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

	  receiver.class_eval do 
	    unloadable
        has_many :project_hot_buttons, :dependent => :destroy
        has_many :hot_buttons, :through => :project_hot_buttons
	  end
	end

	module ClassMethods
	end

	module InstanceMethods
	end
  end
end
