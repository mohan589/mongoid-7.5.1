# frozen_string_literal: true

module Mongoid
  module Atomic
    module Paths
      module Embedded

        # This class encapsulates behavior for locating and updating
        # documents that are defined as an embedded 1-n.
        class Many
          include Embedded

          # Create the new path utility.
          #
          # @example Create the path util.
          #   Many.new(document)
          #
          # @param [ Document ] document The document to generate the paths for.
          def initialize(document)
            @document, @parent = document, document._parent
            @insert_modifier, @delete_modifier ="$push", "$pull"
          end

          # Get the position of the document in the hierarchy. This will
          # include indexes of 1-n embedded associations that may sit above the
          # embedded many.
          #
          # @example Get the position.
          #   many.position
          #
          # @return [ String ] The position of the document.
          def position
            pos = parent.atomic_position
            locator = document.new_record? ? "" : ".#{document._index}"
            "#{pos}#{"." unless pos.blank?}#{document._association.store_as}#{locator}"
          end
        end
      end
    end
  end
end
