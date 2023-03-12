# credit: https://gist.github.com/DivineDominion/83feb20f7a1fa059b915d6e5c412e1b9
require 'kramdown/parser/gfm'

module Jekyll
  module ObsidianMeadow
    class Kramdown::Parser::Obsidian < Kramdown::Parser::GFM

      OBSIDIAN_CALLOUT_START = /^#{OPT_SPACE}>\s*\[\!(.*)\](\+|-)?(.*)$/.freeze

      def handle_obsidian_callouts

      end

      def parse_blockquote
        start_line_number = @src.current_line_number
        result = @src.scan(PARAGRAPH_MATCH)
        callout_start = OBSIDIAN_CALLOUT_START.match(result)
        until @src.match?(self.class::LAZY_END)
          result << @src.scan(PARAGRAPH_MATCH)
        end

        if callout_start
          callout_type = Jekyll::Utils.slugify(callout_start[1])
          callout_text = (callout_start[3].nil? || callout_start[3].empty?) ? callout_start[1] : callout_start[3]
          callout_foldable_sign = callout_start[2]
          callout_class = ''
          if (callout_foldable_sign == '+')
            callout_class = callout_class + ' callout-foldable'
          elsif (callout_foldable_sign == '-')
            callout_class = callout_class + ' callout-foldable folded'
          end
          result.gsub!(OBSIDIAN_CALLOUT_START, '')
          result.gsub!(BLOCKQUOTE_START, '')

          el = new_block_el(:blockquote, nil, {'class' => "meadow-callout #{callout_class}", 'data-type' => "#{callout_type}", "data-title" => "#{callout_text}"}, location: start_line_number)
          # title_el = new_block_el(:p, 3, {'class' => "meadow-callout-title" } , location: start_line_number)
          # title_el.children << new_block_el(:text, callout_text, nil, location: start_line_number)
          # el.children << title_el
          @tree.children << el
          parse_blocks(el, result)
          return true
        end
        result.gsub!(BLOCKQUOTE_START, '')
        el = new_block_el(:blockquote, nil, {'class' => "blockquote"}, location: start_line_number)
        @tree.children << el
        parse_blocks(el, result)
        true
      end
    end
  end
end
