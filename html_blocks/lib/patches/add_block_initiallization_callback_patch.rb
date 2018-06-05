module Patches
  module AddBlockInitiallizationCallbackPatch


    def self.included(base)

      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        before_action :current_page_blocks

      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def current_page_blocks
        current_uri = request.env['PATH_INFO']
        @current_page_blocks = blocks_collection.where(address: current_uri, link_type: 0)
        regexpr_blocks = blocks_collection.where(link_type: 1)
        return unless regexpr_blocks
        regexpr_blocks.each do |block|
          @current_page_blocks << block if block.address.match(current_uri)
        end
      end

      def blocks_collection
        Block
      end

    end

    end
end
