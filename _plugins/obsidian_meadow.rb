require 'nokogiri'

module Jekyll
  module ObsidianMeadow
    def self.supported_docs
      @supported_docs
    end

    def self.supported_docs=(value)
      @supported_docs = value
    end

    def self.backlinks
      @backlinks
    end

    def self.backlinks=(value)
      @backlinks = value
    end

    def self.broken_links
      @broken_links
    end

    def self.broken_links=(value)
      @broken_links = value
    end

    class Generator < Jekyll::Generator
      def generate(site)
        @site = site
        ObsidianMeadow.supported_docs = SupportedDocs.new(site)
        ObsidianMeadow.backlinks = {}
        ObsidianMeadow.broken_links = {}
      end
    end

    Jekyll::Hooks.register :documents, :post_convert do |doc|
      html_doc = Nokogiri::HTML(doc.content)
      link_transformer = InternalLinkTransformer.transform_internal_links(html_doc, doc.url)
      doc_content = link_transformer.content
      doc.content = doc_content
      # TODO: add backlinks and broken links
      link_transformer.links.each do |link|
        if !link.is_external?
          if link.exists? && link.resolved_url.match?(/^#/) == false
            ObsidianMeadow.backlinks[link.resolved_url] = [] if ObsidianMeadow.backlinks[link.resolved_url].nil?
            unless ObsidianMeadow.backlinks[link.resolved_url].any? { |obj| obj['url'] == doc.url }
              ObsidianMeadow.backlinks[link.resolved_url] << {
                'url' => doc.url,
                'title' => doc.data['title']
              }
            end
          else
            ObsidianMeadow.broken_links[link.url] = [] if ObsidianMeadow.broken_links[link.url].nil?
            ObsidianMeadow.broken_links[link.url] << doc.url if ObsidianMeadow.broken_links[link.url].include?(doc.url) == false
          end
        end
      end
    end

    Jekyll::Hooks.register :documents, :post_init do |doc|
      doc.data['last_modified_at'] = File.mtime(doc.path) if doc.data['last_modified_at'].nil?
      doc.data['created_at'] = File.ctime(doc.path) if doc.data['created_at'].nil?
    end

    Jekyll::Hooks.register :site, :post_render do |site|
      # overwrite backlinks and broken links as json dump files in _includes
      File.open('scripts/backlinks.json', 'w') do |file|
        file.write(ObsidianMeadow.backlinks.to_json)
      end

      File.open('scripts/broken_links.json', 'w') do |file|
        file.write(ObsidianMeadow.broken_links.to_json)
      end

      embed_appender = Jekyll::ObsidianMeadow::EmbedAppender.new(site)
      embed_appender.append_embeds
    end

    # Jekyll::Hooks.register :pages, :post_convert do |doc|
    #   html_doc = Nokogiri::HTML(doc.content)
    #   link_transformer = InternalLinkTransformer.transform_internal_links(html_doc, doc.url)
    #   doc_content = link_transformer.content
    #   # TODO: add backlinks and broken links
    #   doc.content = doc_content
    # end

    Jekyll::Hooks.register :site, :after_init do |site|
      Jekyll::ObsidianMeadow::FrontmatterPrepender.prepend_frontmatter(site)
    end

  end

  class StaticFile
    def placeholders
      {
        :collection => @collection.label,
        :path       => cleaned_relative_path,
        :output_ext => "",
        :name       => basename,
        :title      => "",
        :slugified_path => Jekyll::ObsidianMeadow::Utils.slugify_path(cleaned_relative_path),
      }
    end
  end

  class Document
    def url_placeholders
      @url_placeholders ||= Drops::UrlDrop.new(self)
      @url_placeholders = @url_placeholders.merge({"slugified_path" => Jekyll::ObsidianMeadow::Utils.slugify_path(cleaned_relative_path)})
      @url_placeholders
    end
  end
end

