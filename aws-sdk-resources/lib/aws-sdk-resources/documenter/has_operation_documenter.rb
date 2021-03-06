module Aws
  module Resources
    class Documenter
      class HasOperationDocumenter < BaseOperationDocumenter

        def docstring
          docs = []
          docs << super

          if can_return_nil?
            docs << return_message
          elsif argument?
            msg = "Returns a {#{target_resource_class}} resource with "
            msg << "the given `#{argument_name}`."
            docs << msg
          else
            docs << "Returns a {#{target_resource_class}} resource."
          end

          if data_member && resource_class.load_operation
            load_method = resource_class.load_operation.request.method_name
            msg = "Calling this method will call {Client##{load_method}} "
            msg << "unless the resource is already {#data_loaded? loaded}. "
            msg << "No additional API requests are made."
            docs << msg
          else
            msg = "Calling this method will **not** make an API request."
            docs << msg
          end

          docs.join(' ')
        end

        def return_type
          if plural?
            type = ["Array<#{target_resource_class_name}>"]
          else
            type = [target_resource_class_name]
          end
          type << 'nil' if can_return_nil?
          type
        end

        def return_message
          if can_return_nil?
            "Returns a {#{target_resource_class_name}} resource, or `nil` " +
            "if `#data.#{data_member_source}` is `nil`."
          else
            "Returns a {#{target_resource_class_name}} resource."
          end
        end

        def parameters
          if argument?
            [[argument_name, nil]]
          else
            []
          end
        end

        def tags
          tags = super
          if argument?
            tag = "@param [String] #{argument_name} "
            tag << "The {#{target_resource_class_name}##{argument_name}} "
            tag << "identifier."
            tags += YARD::DocstringParser.new.parse(tag).to_docstring.tags
          end
          tags
        end

        def plural?
          @operation.builder.plural?
        end

        def argument?
          @operation.arity > 0
        end

        def can_return_nil?
          data_member
        end

        def data_member
          builder.sources.find { |s| BuilderSources::DataMember === s }
        end

        def data_member_source
          data_member.source
        end

        def argument_name
          argument = builder.sources.find do |source|
            BuilderSources::Argument === source
          end
          argument.target.to_s
        end

      end
    end
  end
end
