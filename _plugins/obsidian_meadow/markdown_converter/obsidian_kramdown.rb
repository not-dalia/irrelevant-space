
module Jekyll
  module ObsidianMeadow
    class ObsidianKramdown < Kramdown::Parser::Obsidian
      def initialize(source, options)
        super
      end
    end

    class Jekyll::Converters::Markdown::ObsidianKramdown < Jekyll::Converters::Markdown::KramdownParser
      def initialize(config)
        @obsidian_kramdown_config = config['obsidian_kramdown'] || {}
        super(config.merge({input: 'Obsidian'}))
      end

      def setup
        super
        @parser = ObsidianKramdown.send(:new, @source, { config: @config.merge({ 'obsidian_kramdown': @obsidian_kramdown_config}) })
      end
    end
  end
end
