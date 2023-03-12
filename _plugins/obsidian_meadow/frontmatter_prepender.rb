module Jekyll
  module ObsidianMeadow
    class FrontmatterPrepender
      def self.prepend_frontmatter(site)
        if Config.prepend_frontmatter_enabled
          site.collections.each do |collection|
            if !Config.prepend_frontmatter_excluded_collections.include?(collection[0])
              # filtering entries so we don't prepend to excluded files
              EntryFilter.new(site).filter(collection[1].entries).each do |entry|
                entry_path = collection[1].collection_dir(entry)
                if Utils.is_markdown_file?(entry_path) && Jekyll::Utils.has_yaml_header?(entry_path) == false
                  prepend_frontmatter_to_entry(entry, entry_path)
                end
              end
            end
          end
        end
      end

      def self.prepend_frontmatter_to_entry(entry, entry_path)
        Jekyll.logger.info "Appending frontmatter to #{entry}"
        # get entry file name without extension or path
        entry_name = Utils.get_filename_without_ext(entry)
        file_content = File.read(entry_path)
        file_content.prepend("---\ntitle: #{entry_name}\n---\n\n")
        File.write(entry_path, file_content)
      end
    end
  end
end
