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
              unless doc.data['secret'] == true
                ObsidianMeadow.backlinks[link.resolved_url] << {
                  'url' => doc.url,
                  'title' => doc.data['title']
                }
              end
            end
          else
            ObsidianMeadow.broken_links[link.url] = [] if ObsidianMeadow.broken_links[link.url].nil?
            ObsidianMeadow.broken_links[link.url] << doc.url if ObsidianMeadow.broken_links[link.url].include?(doc.url) == false
          end
        end
      end
    end

    def run_command(command)
      `#{command}`.strip
    end

    def get_first_commit_date(file)
      first_commit_date = run_command("git log --diff-filter=A --follow --format=%aD #{file} | tail -1")
      return first_commit_date.chomp
    end

    def get_last_commit_date(file)
      last_commit_date = run_command("git log -1 --format=%aD #{file}")
      return last_commit_date.chomp
    end

    Jekyll::Hooks.register :documents, :post_init do |doc|
      # doc.data['created_at'] = File.ctime(doc.path) if doc.data['created_at'].nil? || doc.data['created_at'].empty?
      # doc.data['last_updated_at'] = File.mtime(doc.path) if doc.data['last_updated_at'].nil? || doc.data['last_updated_at'].empty?
      doc.data['created_at'] = get_first_commit_date(doc.path) if doc.data['created_at'].nil? || doc.data['created_at'].empty?
      doc.data['last_updated_at'] = get_last_commit_date(doc.path) if doc.data['last_updated_at'].nil? || doc.data['last_updated_at'].empty?
      Jekyll.logger.info "#{doc.path}", "Last updated at: #{doc.data['last_updated_at'].to_s}"
    end

    Jekyll::Hooks.register :site, :post_render do |site|
      # overwrite backlinks and broken links as json dump files in _includes

      destination = site.dest
      scripts_path = File.join(destination, 'scripts')
      FileUtils.mkdir_p(scripts_path) unless File.directory?(scripts_path)

      backlinks_path = File.join(destination, 'scripts/backlinks.json')
      File.open(backlinks_path, 'w') do |file|
        file.write(ObsidianMeadow.backlinks.to_json)
      end

      broken_links_path = File.join(destination, 'scripts/broken_links.json')
      File.open(broken_links_path, 'w') do |file|
        file.write(ObsidianMeadow.broken_links.to_json)
      end

      Jekyll.logger.info "Obsidian Meadow:", "Backlinks and broken links written to #{backlinks_path} and #{broken_links_path}"
      embed_appender = Jekyll::ObsidianMeadow::EmbedAppender.new(site)
      embed_appender.append_embeds

      callout_formatter = Jekyll::ObsidianMeadow::CalloutFormatter.new(site)
      callout_formatter.format_callouts
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
