require 'kramdown/parser/gfm'

module Jekyll
  module ObsidianMeadow
    class Kramdown::Parser::Obsidian < Kramdown::Parser::GFM
      def initialize(source, options)
        super
        # Override existing Table parser to use our own start Regex which adds a check for wikilinks
        @@parsers.delete(:table) #Data(:table, TABLE_START, nil, "parse_table")
        @@parsers.delete(:blockquote)
        self.class.define_parser(:table, TABLE_START)
        self.class.define_parser(:blockquote, BLOCKQUOTE_START)

        @span_parsers.unshift(:wikilinks)
        @span_parsers.unshift(:wikilink_embeds)
        # @span_parsers.unshift(:obsidian_callouts)
      end

      # Override Kramdown table pipe check so we can write `[[pagename|Anchor Text]]`.
      # https://github.com/gettalong/kramdown/blob/master/lib/kramdown/parser/kramdown/table.rb
      # Regex test suite: https://regexr.com/5rb9q
      TABLE_PIPE_CHECK = /^(?:\|(?!\[\[)|[^\[]*?(?!\[\[)[^\[]*?\||.*?(?:\[\[[^\]]+\]\]).*?\|)/.freeze  # Fail for wikilinks in same line
      TABLE_LINE = /#{TABLE_PIPE_CHECK}.*?\n/.freeze  # Unchanged
      TABLE_START = /^#{OPT_SPACE}(?=\S)#{TABLE_LINE}/.freeze  # Unchanged

      # override the default blockquote parser to allow for callouts
      # BLOCKQUOTE_START = /^#{OPT_SPACE}>(?!\s*\[\!.*\])/.freeze
    end
  end
end
