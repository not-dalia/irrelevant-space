require 'uri'

module Jekyll
  module ObsidianMeadow
    class Link
      attr_reader :url, :resolved_url, :href, :anchor, :link
      def initialize(link)
        @link = link
        @href = link['href']
        @url, @anchor = @href.split('#')
        @resolved_url = resolve
      end

      def is_external?
        return false if @url.nil? || @url.empty?
        (@url =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]) == 0
      end

      def resolve
        if is_external?
          @href
        elsif @url.nil? || @url.empty?
          @href
        else
          docs = ObsidianMeadow.supported_docs.find_matching_docs(self)
          if file_type == 'doc'
            # TODO: actually check if the resolved URL is correct
            resolved_url = docs.select { |doc| doc['type'] == 'url' }&.first
            resolved_url = docs.select { |doc| doc['type'] == 'possible_url' }&.first if resolved_url.nil?
            resolved_url = resolved_url['meadowDoc'].url.url if resolved_url
            resolved_url
          else
            # TODO: actually check if the resolved URL is correct
            docs[0]['file']&.url
          end
        end
      end

      def exists?
        if is_external?
          true
        else
          @resolved_url? true : false
        end
      end

      def slug
        Utils.get_slug_from_url(@url) if @url
      end

      def extname
        Utils.get_extname_from_url(@url) if @url
      end

      def file_type
        Utils.get_extname_type(extname)
      end
    end
  end
end
