module Jekyll
  module ObsidianMeadow
    class TopicPageGenerator < Jekyll::Generator
      safe true

      def generate(site)
        @topics = {}
        topic_arr = []
        site.documents.each do |doc|
          if doc.data['secret'] == true
            next
          end
          doc.data['topics']&.each do |topic|
            slugified_topic = Jekyll::Utils.slugify(topic)
            @topics[slugified_topic] ||= {
              'name' => topic,
              'linked_docs' => [],
            }
            @topics[slugified_topic]['linked_docs'] << doc
          end
        end
        @topics.each do |topic, topic_data|
          docs = topic_data['linked_docs']
          topic_name = topic_data['name']
          topic_page = TopicPage.new(site, topic, topic_name, docs)
          site.pages << topic_page
          topic_arr << topic_page
        end
        site.config['topics'] = topic_arr.sort_by { |topic| topic['linked_docs'].size }.reverse
      end
    end

    class TopicPage < Jekyll::Page
      def initialize(site, topic, topic_name, docs)
        @site = site
        @base = site.source
        @dir = topic
        @basename = 'index'      # filename without the extension.
        @ext      = '.html'      # the extension.
        @name     = 'index.html' # basically @basename + @ext.

        @data = {
          'linked_docs' => docs,
          'topic' => topic_name,
          'size' => docs.size,
        }

        data.default_proc = proc do |_, key|
          site.frontmatter_defaults.find(relative_path, :topics, key)
        end
      end

      def url_placeholders
        {
          :path       => @dir,
          :topic   => @dir,
          :category   => @dir,
          :basename   => basename,
          :output_ext => output_ext,
        }
      end
    end
  end
end
