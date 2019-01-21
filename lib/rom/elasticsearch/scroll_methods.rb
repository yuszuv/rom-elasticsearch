module ROM
  module Elasticsearch
    # Dataset's scoll methods
    #
    # @see Dataset
    #
    # @api public
    module ScrollMethods
      # Return dataset with :scroll set
      #
      # @param [String] ttl
      #
      # @return [Dataset]
      #
      # @api public
      def scroll(ttl)
        params(scroll: ttl)
      end

      # @api private
      def scroll_enumerator(client, response)
        Enumerator.new do |yielder|
          loop do
            hits = response.fetch('hits').fetch('hits')

            break if hits.empty?

            hits.each do |result|
              yielder.yield(result)
            end

            response = client.scroll(
              scroll_id: current_response.fetch('_scroll_id'),
              scroll: params[:scroll],
            )
          end
        end
      end
    end
  end
end
