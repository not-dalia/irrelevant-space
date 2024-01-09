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
                if Utils.is_markdown_file?(entry_path)
                  if Jekyll::Utils.has_yaml_header?(entry_path) == false
                    prepend_frontmatter_to_entry(entry, entry_path)
                  end
                  add_missing_frontmatter_to_entry(entry, entry_path)
                end
              end
            end
          end
        end
      end

      def self.prepend_frontmatter_to_entry(entry, entry_path)
        Jekyll.logger.info "Prepending frontmatter to #{entry}"
        file_content = File.read(entry_path)
        file_content.prepend("---\n\n---\n\n")
        File.write(entry_path, file_content)
      end

      def self.add_missing_frontmatter_to_entry(entry, entry_path)
        Jekyll.logger.info "Adding missing frontmatter to #{entry}"
        file_content = File.read(entry_path)
        yaml_data = Utils.read_yaml(entry_path)
        Jekyll.logger.info "YAML data for #{entry}:", "#{yaml_data}"
        # get entry file name without extension or path
        entry_name = Utils.get_filename_without_ext(entry)
        # created_at = yaml_data['created_at'] || DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')
        # last_updated_at = yaml_data['last_updated_at'] || created_at
        type = yaml_data['type'] || 'note'
        add_yaml_string = ""
        add_yaml_string += "title: #{entry_name}\n" if yaml_data['title'].nil? || yaml_data['title'].empty?
        # add_yaml_string += "created_at: #{created_at}\n" if yaml_data['created_at'].nil? || yaml_data['created_at'].to_s.empty?
        # add_yaml_string += "last_updated_at: #{last_updated_at}\n" if yaml_data['last_updated_at'].nil? || yaml_data['last_updated_at'].to_s.empty?
        add_yaml_string += "type: #{type}\n" if yaml_data['type'].nil? || yaml_data['type'].empty?


        Jekyll.logger.info "Added YAML data for #{entry}:", "#{add_yaml_string}"
        if (!add_yaml_string.nil? && !add_yaml_string.empty?)
          # find where to insert the new data, assuming frontmatter is present
          # we can insert right after the first ---\n
          first_frontmatter_start = file_content.index("---\n")
          # insert the new data
          file_content.insert(first_frontmatter_start + 4, add_yaml_string)
          File.write(entry_path, file_content)
        end
      end
    end
  end
end
