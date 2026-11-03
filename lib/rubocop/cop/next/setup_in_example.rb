module RuboCop
  module Cop
    module Next
      class SetupInExample < ::RuboCop::Cop::RSpec::Base
        ALLOWED_METHODS = ['is_expected', 'pending', 'raise', 'skip'].freeze
        ASSIGNMENT_TYPES = %i[and_asgn lvasgn masgn op_asgn or_asgn].freeze
        EXPECTATION_PREFIX = 'expect'.freeze
        MSG_ASSIGNMENT = 'Move this assignment out of the example - declare it with `let!` or set it up in `before`.'.freeze
        MSG_SETUP = 'Move this setup out of the example - only expectations belong in an example. Set it up in `before`.'.freeze

        # @!method example?(node)
        def_node_matcher :example?, '(block (send nil? #Examples.all ...) args !nil?)'

        def on_block(node) = example?(node) && statements(node.body).each { |statement| register_offense(statement) }

        private

        def allowed_methods = cop_config.fetch('AllowedMethods', ALLOWED_METHODS)
        def assignment?(node) = ASSIGNMENT_TYPES.include?(node.type)
        def call?(node) = node.any_block_type? || node.type?(:send, :csend)
        def expectation?(name) = name.start_with?(EXPECTATION_PREFIX) || allowed_methods.include?(name)

        def assignment_range(node)
          target = node.masgn_type? ? node.children.first : node
          target = target.children.first if target.type?(:and_asgn, :op_asgn, :or_asgn)

          target.loc.respond_to?(:name) ? target.loc.name : target.source_range
        end

        def outer_send(node)
          node = node.send_node while node.any_block_type?

          node
        end

        def register_offense(statement)
          return add_offense(assignment_range(statement), message: MSG_ASSIGNMENT) if assignment?(statement)
          return unless call?(statement)

          root = root_send(statement)

          return if root && expectation?(root.method_name.to_s)

          add_offense((root || outer_send(statement)).loc.selector, message: MSG_SETUP)
        end

        def root_send(node)
          return root_send(node.send_node) if node.any_block_type?
          return unless node.type?(:send, :csend)
          return root_send(node.receiver) if node.receiver

          node
        end

        def statements(node)
          return node.children.flat_map { |child| statements(child) } if node.begin_type?
          return statements(node.body) if node.any_block_type? && node.body

          [node]
        end
      end
    end
  end
end
