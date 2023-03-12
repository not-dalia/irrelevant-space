module Jekyll
  module ObsidianMeadow
    class Config
      @@config = {}
      @@initialized = false

      def self.initialize(config)
        @@config = config['obsidian_meadow']
        @@extnames = (config["markdown_ext"] || "markdown,mkdown,mkdn,mkd,md").split(",").map! { |e| ".#{e.downcase}" }
        @@extnames << ".html"
        @@enabled = @@config['enabled'].nil? || @@config['enabled']
        @@excluded_collections = @@config['excluded_collections'] || []
        @@excluded_pages = @@config['excluded_pages'] || []
        @@assets_folder_path = @@config['assets_folder_path'] || 'assets'
        @@prepend_frontmatter = @@config['prepend_frontmatter'] || {}
        @@prepend_frontmatter_enabled = @@prepend_frontmatter['enabled'] || false
        @@prepend_frontmatter_excluded_collections = @@prepend_frontmatter['excluded_collections'] || []

        @@initialized = true
      end

      def self.enabled
        initialize_config unless @@initialized
        @@enabled
      end

      def self.excluded_collections
        initialize_config unless @@initialized
        @@excluded_collections
      end

      def self.excluded_pages
        initialize_config unless @@initialized
        @@excluded_pages
      end

      def self.assets_folder_path
        initialize_config unless @@initialized
        @@assets_folder_path
      end

      def self.prepend_frontmatter_enabled
        initialize_config unless @@initialized
        @@prepend_frontmatter_enabled
      end

      def self.prepend_frontmatter_excluded_collections
        initialize_config unless @@initialized
        @@prepend_frontmatter_excluded_collections
      end

      def self.extnames
        initialize_config unless @@initialized
        @@extnames
      end

      private_class_method def self.initialize_config
        config = Jekyll.configuration({})
        Config.initialize(config)
      end
    end
  end
end
