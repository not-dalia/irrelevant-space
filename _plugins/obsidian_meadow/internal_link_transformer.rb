module Jekyll
  module ObsidianMeadow
    class InternalLinkTransformer
      attr_reader :links
      def self.transform_internal_links(html_doc, doc_url)
        self.new(html_doc, doc_url)
      end

      def initialize(html_doc, doc_url)
        @html_doc = html_doc
        @links = []
        @html_doc.css('a').each do |l|
          link = Link.new(l)
          if link.is_external?
            classNames = l['class'] ? l['class'].split(' ') : []
            classNames << 'external-link' if classNames.include?('external-link') == false
            l['class'] = classNames.join(' ')
            l['target'] = '_blank'
          else
            if link.exists?
              classNames = l['class'] ? l['class'].split(' ') : []
              classNames << 'internal-link' if classNames.include?('internal-link') == false
              l['class'] = classNames.join(' ')
              href = link.resolved_url
              href = href + '#' + link.anchor if link.anchor && href.include?('#') == false
              l['href'] = href
              if classNames.include?('embed-link')
                l['data-embed-url'] = link.resolved_url
                l['data-embed-fragment'] = link.anchor
              end
            else
              classNames = l['class'] ? l['class'].split(' ') : []
              classNames << 'broken-link' if classNames.include?('broken-link') == false
              l['class'] = classNames.join(' ')
            end
          end
          @links << link
        end
        content
      end

      def content
        @html_doc.css('body').inner_html
      end
    end
  end
end
