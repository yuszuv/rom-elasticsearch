require 'dry/core/inflector'
require 'elasticsearch'
require 'uri'

require 'rom/gateway'
require 'rom/elasticsearch/dataset'

module ROM
  module Elasticsearch
    # ElasticSearch gateway
    #
    # @example basic configuration
    #   conf = ROM::Configuration.new(:elasticsearch, 'http://localhost:9200/rom-test')
    #
    #   class Posts < ROM::Relation[:elasticsearch]
    #     schema(:posts) do
    #       attribute :id, Types::Int
    #       attribute :title, Types::String
    #     end
    #
    #     def like(title)
    #       query(prefix: { title: title })
    #     end
    #   end
    #
    #   conf.register_relation(Posts)
    #
    #   rom = ROM.container(conf)
    #
    #   posts = rom.relations[:posts]
    #
    #   posts.command(:create).call(id: 1, title: 'Hello World')
    #
    #   posts.like('Hello').first
    #
    # @api public
    class Gateway < ROM::Gateway
      adapter :elasticsearch

      # @!attribute [r] client
      #   @return [::Elasticsearch::Client] configured ES client
      attr_reader :client

      # @!attribute [r] root
      #   @return [Dataset] root dataset
      attr_reader :root

      # @api private
      def initialize(url, log: false)
        url = URI.parse(url)
        @client = ::Elasticsearch::Client.new(host: "#{url.host}:#{url.port || 9200}", log: log)
        @root = Dataset.new(@client, params: { index: url.path[1..-1] })
      end

      # Return true if a dataset with the given index exists
      #
      # @return [Boolean]
      #
      # @api public
      def dataset?(index)
        client.indices.exists?(index: index)
      end
      alias_method :index?, :dataset?

      # Get a dataset by its type
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(type)
        root.params(type: Dry::Core::Inflector.singularize(type))
      end
      alias_method :[], :dataset
    end
  end
end
