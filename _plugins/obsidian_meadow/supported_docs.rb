module Jekyll
  module ObsidianMeadow
    class SupportedDocs
      attr_reader :docs, :assets
      def initialize(site)
        @site = site
        @docs = []
        @assets = {}

        @docs_urls = HashArray.new

        if Config.enabled
          init_supported_docs
        end
      end

      def find_matching_docs(link)
        case link.file_type
        when 'doc'
          find_in_docs(link)
        when 'image', 'video', 'audio', 'pdf'
          find_in_assets(link)
        when 'unsupported'
          Jekyll.logger.info "unsupported"
          return []
        end
      end

      def find_in_docs(link)
        stripped_url = Utils.get_url_without_ext(link.url)&.downcase
        filename = Utils.get_slug_from_url(link.url)&.downcase
        slug = Utils.slugify_path(Utils.get_slug_from_url(link.url)&.downcase)
        possible_urls = []
        possible_urls = possible_urls + @docs_urls[stripped_url] if @docs_urls.key?(stripped_url)
        possible_urls = possible_urls + @docs_urls[filename] if @docs_urls.key?(filename)
        possible_urls = possible_urls + @docs_urls[slug] if @docs_urls.key?(slug)
        possible_urls
      end

      def find_in_assets(link)
        filename = link.url.split('/').last
        if @assets.key?("assets/#{filename}")
          return [@assets["assets/#{filename}"]]
        else
          return []
        end
      end

      def add_doc(doc)
        meadowDoc = MeadowDocument.new(doc)
        @docs << meadowDoc
        @docs_urls.add(meadowDoc.url.url_no_ext, {'meadowDoc' => meadowDoc, 'type' => 'url'})
        meadowDoc.possible_urls.each do |url|
          @docs_urls.add(url.url_no_ext, {'meadowDoc' => meadowDoc, 'type' => 'possible_url'})
        end
      end

      def init_supported_docs
        @site.collections.each do |collection|
          if !Config.excluded_collections.include?(collection[0])
            collection[1].docs.each do |doc|
              if Utils.is_md_or_html_file?(doc)
                add_doc(doc)
              end
            end
          end
        end

        unless Config.excluded_collections.include?('pages')
          @site.pages.each do |page|
            if Utils.is_md_or_html_file?(page) && !Config.excluded_pages.include?(page.path)
              add_doc(page)
            end
          end
        end

        @site.static_files.each do |file|
          collection = file.instance_variable_get(:@collection)
          if collection.nil? || !Config.excluded_collections.include?(collection[0])
            @assets[Utils.get_url_stripped(file.url)] = {
              'file' => file,
              'type' => Utils.get_extname_type(file.extname)
            }
          end
        end
      end
    end

    class HashArray < Hash
      def initialize
        super { |hash, key| hash[key] = [] }
      end

      def add(key, value)
        self[key] << value
      end
    end
  end
end
