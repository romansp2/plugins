module Redmine
	module IssueBlock
	  module IssuePatch
	    def self.included(base)
	      base.extend(ClassMethods)
	      base.send(:include, InstanceMethods)

          
	      base.class_eval do
	      	unloadable # Send unloadable so it will not be unloaded in development
	      	eval <<-EOF
	      	  class BlockPermissionsAttributeCoder
			    def self.load(str)
			      str.to_s.scan(/:([a-z0-9_]+)/).flatten.map(&:to_sym)
			    end

			    def self.dump(value)
			      YAML.dump(value)
			    end
			  end    
            EOF
	      	
            #attr_accessor :block_all_actions, :block_only_watchers
		    serialize :block_permissions, ::Issue::BlockPermissionsAttributeCoder
	      end

	    end

	    module ClassMethods
	    	
	    end

	    module InstanceMethods
	      def block_all_actions=(only)
		    if only
		      self.block_permissions = []
		      self.block_permissions << :block_all_actions
		    else
		      self.block_permissions.delete_if{|perm| perm == :block_all_actions} unless self.block_permissions.nil?
		    end
		  end
		  def block_all_actions?
		  	(return false) if self.block_permissions.nil?
		    self.block_permissions.include?(:block_all_actions) 
		  end
		  #
		  def block_only_watchers=(only)
		    if only
		      self.block_permissions = []
		      self.block_permissions << :block_only_watchers
		    else
		      self.block_permissions.delete_if{|perm| perm == :block_only_watchers} unless self.block_permissions.nil?
		    end
		  end
		  def block_only_watchers?
		  	(return false) if self.block_permissions.nil?
		    self.block_permissions.include?(:block_only_watchers) 
		  end
	    end 
	  end
	end
end

