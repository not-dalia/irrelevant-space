# credit: https://gist.github.com/DivineDominion/83feb20f7a1fa059b915d6e5c412e1b9
require 'kramdown/parser/gfm'

module Jekyll
  module ObsidianMeadow
    class Kramdown::Parser::Obsidian < Kramdown::Parser::GFM

      WIKILINKS_MATCH = /\[\[(.*?)\]\]\n*/.freeze
      WIKILINK_LINK_MATCH = /(?<!\!)#{WIKILINKS_MATCH}/.freeze
      WIKILINK_EMBED_MATCH = /\!#{WIKILINKS_MATCH}/.freeze
      define_parser(:wikilinks, WIKILINK_LINK_MATCH, '\[\[')
      define_parser(:wikilink_embeds, WIKILINK_EMBED_MATCH, '\!\[\[')

      def parse_wikilinks
        line_number = @src.current_line_number

        # Advance parser position
        @src.pos += @src.matched_size

        wikilink = Wikilink.parse(@src[1])
        el = Element.new(:a, nil, {'href' => wikilink.url, 'title' => wikilink.title, 'class' => 'wikilink internal-link'}, location: line_number)
        add_text(wikilink.title, el)
        @tree.children << el

        el
      end

      def parse_wikilink_embeds
        line_number = @src.current_line_number

        # Advance parser position
        @src.pos += @src.matched_size

        wikilink = Wikilink.parse(@src[1])
        embed_el = new_block_el(:blockquote, nil, {'class' => 'wikilink-embed', 'data-config' => wikilink.pipe_part}, location: line_number)
        link_el = Element.new(:a, nil, {'href' => wikilink.url, 'class' => 'internal-link embed-link'}, location: line_number)
        add_text(wikilink.title || wikilink.url , link_el)
        embed_el.children << link_el
        # parse_spans(embed_el)
        @tree.children << embed_el

        embed_el
      end

      # [[page_name|Optional title]]
      # For a converter that uses the available pages, see: <https://github.com/metala/jekyll-wikilinks-plugin/blob/master/wikilinks.rb>
      class Wikilink
        def self.parse(text)
          text_parts = text.split('|', 2)
          link_parts = text_parts[0].split('#', 2)
          name = link_parts[0]
          anchor_text = link_parts[1]
          title = text_parts[1] || name
          Jekyll.logger.info "-------------------"
          Jekyll.logger.info "text  : #{text}"
          self.new(name, title, anchor_text)
        end

        attr_accessor :name, :pipe_part
        attr_reader :match

        def initialize(name, title, anchor=nil)
          @name = name.nil? || name.empty? ? '' : "#{Utils.slugify_path(name)}"
          @name = '/' + @name unless @name.empty? || name.include?('/')
          @title = title
          @pipe_part = title
          @anchor = anchor
          Jekyll.logger.info "name  : #{@name}"
          Jekyll.logger.info "title : #{title}"
          Jekyll.logger.info "anchor: #{anchor}"
          Jekyll.logger.info "url   : #{url}"
          Jekyll.logger.info "-------------------"
        end

        def title
          title_arr = [(@title || @name)]
          title_arr << @anchor unless @anchor.nil? || @anchor.empty?
          title_arr.join('#')
        end

        def anchor
          if (@anchor.nil? || @anchor.empty?)
            anchor = ''
          else
            anchor = "#"
            anchor += "^" if @anchor.strip.start_with?("^")
            anchor += Utils.slugify_path(@anchor)
            # @anchor = anchor
          end
          anchor
        end

        def url
          "#{(@name + anchor).downcase}"
        end
      end
    end
  end
end
