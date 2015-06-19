module Disposable
  class Twin
    # Read all properties at twin initialization time from model.
    # Simply pass through all properties from the model to the respective twin writer method.
    # This will result in all twin properties/collection items being twinned, and collections
    # being Collection to expose the desired public API.
    module Setup
      # test is in incoming hash? is nil on incoming model?

      def initialize(model, options={})
        @fields = {}
        @model  = model
        @mapper = mapper_for(model) # mapper for model.

        setup_properties!(model, options)
      end

    private
      def mapper_for(model)
        model
      end

      def setup_properties!(model, options)
        schema.each do |dfn|
          next if dfn[:readable] == false

          name  = dfn.name
          value = options[name.to_sym] || mapper.send(name) # model.title.

          send(dfn.setter, value)
        end

        @fields.merge!(options) # FIXME: hash/string. # FIXME: call writer!!!!!!!!!!
        # from_hash(options) # assigns known properties from options.
      end
    end # Setup
  end
end