require 'erb'

module Jekyll
  module ObsidianMeadow
    class MeadowDocument
      attr_reader :doc, :title, :slug, :url, :filename, :dir_url, :possible_urls
      def initialize(doc)
        @doc = doc
        @title = doc.data['title']
        @slug = doc.data['slug']
        @url = MeadowDocURL.new(doc.url)
        @filename = doc.basename
        @dir_url = File.dirname(@url.url_stripped)
        @dir_url += '/' unless @dir_url.end_with?('/')
        generate_possible_urls
      end

      def generate_possible_urls
        encoded_slug = ERB::Util.url_encode(@slug) if @slug
        encoded_title = ERB::Util.url_encode(@title) if @title

        @possible_urls = []
        @possible_urls << MeadowDocURL.new(@dir_url + Jekyll::Utils.slugify(@slug)) if @slug
        @possible_urls << MeadowDocURL.new(@dir_url + Jekyll::Utils.slugify(@title)) if @title
        @possible_urls << MeadowDocURL.new(@dir_url + encoded_slug) if @slug
        @possible_urls << MeadowDocURL.new(@dir_url + encoded_title) if @title
        @possible_urls << MeadowDocURL.new(Jekyll::Utils.slugify(@slug)) if @slug
        @possible_urls << MeadowDocURL.new(encoded_slug) if @slug
      end
    end

    class MeadowDocURL
      attr_reader :url, :url_no_ext, :url_stripped
      def initialize(url)
        @url = url
        @url_no_ext = Utils.get_url_without_ext(@url)
        @url_stripped = Utils.get_url_stripped(@url)
      end
    end
  end
end
