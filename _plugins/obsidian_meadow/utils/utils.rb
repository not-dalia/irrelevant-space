module Jekyll
  module ObsidianMeadow
    class Utils
      @supported_image_exts = ['.png', '.webp', '.jpg', '.jpeg', '.gif', '.bmp', '.svg']
      @supported_audio_exts = ['.mp3', '.webm', '.wav', '.m4a', '.ogg', '.3gp', '.flac']
      @supported_video_exts = ['.mp4', '.webm', '.ogv', '.mov', '.mkv']
      @supported_pdf_exts = ['.pdf']
      @supported_docs = ['.md', '.markdown', '.html']
      def self.is_markdown_file?(file)
        file.end_with?('.md') || file.end_with?('.markdown')
      end

      def self.get_filename_without_ext(file)
        file.split('/').last.split('.').first
      end

      def self.is_md_or_html_file?(file)
        Config.extnames.include? file.extname&.downcase
      end

      def self.get_slug_from_url(url)
        url.strip.gsub(/\/$/, '').split('/').last&.split('.')&.first
      end

      def self.get_extname_from_url(url)
        url.strip&.gsub(/\/$/, '').split('/')&.last&.match(/\.(\w+)$/)&.captures&.first&.downcase
      end

      def self.is_supported_extname?(extname)
        (@supported_image_exts + @supported_audio_exts + @supported_video_exts + @supported_pdf_exts + @supported_docs).include? extname&.downcase
      end

      def self.get_extname_type(extname)
        extname = '.' + extname unless extname.nil? || extname.empty? || extname.start_with?('.')
        if @supported_image_exts.include? extname&.downcase
          'image'
        elsif @supported_audio_exts.include? extname&.downcase
          'audio'
        elsif @supported_video_exts.include? extname&.downcase
          'video'
        elsif @supported_pdf_exts.include? extname&.downcase
          'pdf'
        elsif @supported_docs.include? extname&.downcase
          'doc'
        elsif extname.nil?
          'doc'
        else
          'unsupported'
        end
      end

      # def self.slugify_path(text)
      #   text&.downcase.gsub(/[^0-9a-z.]+/, '-').gsub(/^-|-$/, '')
      # end

      def self.get_url_stripped(url)
        # remove trailing slash
        url.gsub(/\/$/, '')&.gsub(/^\//, '')&.downcase
      end

      def self.get_url_without_ext(url)
        url_stripped = self.get_url_stripped(url)
        extension = File.extname(url_stripped)
        no_ext_url = url_stripped.gsub(/#{extension}$/, "")
        no_ext_url
      end

      def self.slugify_path(path)
        # Replace any backslashes with forward slashes
        path = path.gsub('\\', '/')
        # Slugify the path
        path = path.downcase.gsub(%r{[^a-z0-9./-]+}, '-').gsub(%r{/+}, '/').gsub(/^-|-$/, '')
        # path = path&.downcase.gsub(/[^0-9a-z.]+/, '-').gsub(/^-|-$/, '').gsub(%r{/+}, '/')
        # Remove leading and trailing slashes
        path = path.gsub(%r{^/|/$}, '')
        path
      end

      def self.read_yaml(path)
        begin
          content = File.read(path)
          if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
            content = Regexp.last_match.post_match
            data = SafeYAML.load(Regexp.last_match(1))
          end
        rescue Psych::SyntaxError => e
          Jekyll.logger.warn "YAML Exception reading #{path}: #{e.message}"
        rescue StandardError => e
          Jekyll.logger.warn "Error reading file #{path}: #{e.message}"
        end
        data ||= {}
        data
      end
    end
  end
end
