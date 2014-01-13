module MultipleMan
  class ModelSubscriber

    @subscriptions = []
    class << self
      attr_accessor :subscriptions

      def register(klass, options)
        self.subscriptions << new(klass, options)
      end
    end

    def initialize(klass, options)
      self.klass = klass
      self.options = options
    end

    attr_reader :klass
    attr_accessor :options

    def create(payload)
      model = find_model(payload[:id])
      model.attributes = payload[:data]
      model.save!
    end

    alias_method :update, :create

    def destroy(payload)
      model = find_model(payload[:id])
      model.destroy!
    end

    def routing_key
      RoutingKey.new(klass).to_s
    end

    def queue_name
      "#{MultipleMan.configuration.topic_name}.#{MultipleMan.configuration.app_name}.#{klass.name}"
    end

  private

    def find_model(id)
      klass.find_or_initialize_by(multiple_man_identifier: id)
    end

    attr_writer :klass

  end
end