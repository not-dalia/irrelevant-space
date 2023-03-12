require 'nokogiri'

module Jekyll
  module ObsidianMeadow
    class CalloutFormatter
      def initialize(site)
        @site = site
        @supported_docs = ObsidianMeadow.supported_docs
      end

      def format_callouts
        @supported_docs.docs.each do |doc|
          html_doc = Nokogiri::HTML(doc.doc.output)
          html_doc.css('blockquote.meadow-callout').each do |callout|
            formatted_callout = format_callout(callout)
          end
          doc.doc.output = html_doc.to_html
        end
      end

      def format_callout(callout)
        # if class containes formatted-callout, skip
        if callout['class'] && callout['class'].split(' ').include?('formatted-callout')
          return
        end
        # check for inner callouts
        callout.css('blockquote.meadow-callout').each do |inner_callout|
          format_callout(inner_callout)
        end
        # format callout
        callout_type = callout['data-type']&.strip
        callout_title = callout['data-title']&.strip
        callout_content = callout.inner_html&.strip
        callout_properties = get_callout_properties(callout_type)
        callout_icon = callout_properties[:icon]
        callout_name = callout_properties[:name]

        # create icon element <i>
        callout_icon_element = Nokogiri::XML::Node.new('i', callout)
        callout_icon_element['class'] = "meadow-callout-icon"
        callout_icon_element['icon-name'] = callout_icon
        #create span for title
        callout_title_span = Nokogiri::XML::Node.new('span', callout)
        callout_title_span.content = callout_title || callout_name

        callout_title_element = nil
        if callout['class'] && callout['class'].split(' ').include?('callout-foldable')
          callout_title_element = Nokogiri::XML::Node.new('button', callout)
          callout_title_element['class'] = "meadow-callout-title"
          callout_id = "callout-#{rand(36**9).to_s(36)}"

          # aria-label="Toggle callout" tabindex="0" onclick="toggleCallout(this)" aria-controls="${calloutId}" aria-expanded="${expanded}"
          callout_title_element['aria-label'] = "Toggle callout"
          callout_title_element['tabindex'] = "0"
          callout_title_element['onclick'] = "toggleMeadowCallout && toggleMeadowCallout(this)"
          callout_title_element['aria-controls'] = callout_id
          callout_title_element['aria-expanded'] = callout['class'].split(' ').include?('folded') ? "false" : "true"
          callout['id'] = callout_id

          callout_icon_toggle = Nokogiri::XML::Node.new('i', callout)
          callout_icon_toggle['class'] = "meadow-callout-icon meadow-callout-icon-toggle"
          callout_icon_toggle['icon-name'] = "chevron-down"

          callout_title_element.add_child(callout_icon_element)
          callout_title_element.add_child(callout_title_span)
          callout_title_element.add_child(callout_icon_toggle)
        else
          callout_title_element = Nokogiri::XML::Node.new('div', callout)
          callout_title_element['class'] = "meadow-callout-title"
          callout_title_element.add_child(callout_icon_element)
          callout_title_element.add_child(callout_title_span)
        end
        callout_content_wrapper = Nokogiri::XML::Node.new('div', callout)
        callout_content_wrapper['class'] = "meadow-callout-content"
        callout_content_wrapper.inner_html = callout_content

        callout['class'] = callout['class'] + " formatted-callout meadow-callout-#{callout_name}"
        callout.inner_html = ""
        callout.add_child(callout_title_element)
        callout.add_child(callout_content_wrapper)

        callout
      end

      def get_callout_properties(type)
        callout_map = {
          'abstract' => { name: 'abstract', icon: 'clipboard-list' },
          'summary' => { name: 'abstract', icon: 'clipboard-list' },
          'tldr' => { name: 'abstract', icon: 'clipboard-list' },
          'info' => { name: 'info', icon: 'info' },
          'todo' => { name: 'todo', icon: 'check-circle-2' },
          'tip' => { name: 'tip', icon: 'flame' },
          'hint' => { name: 'tip', icon: 'flame' },
          'important' => { name: 'tip', icon: 'flame' },
          'warning' => { name: 'warning', icon: 'alert-triangle' },
          'caution' => { name: 'warning', icon: 'alert-triangle' },
          'attention' => { name: 'warning', icon: 'alert-triangle' },
          'failure' => { name: 'failure', icon: 'x' },
          'fail' => { name: 'failure', icon: 'x' },
          'missing' => { name: 'failure', icon: 'x' },
          'success' => { name: 'success', icon: 'check' },
          'check' => { name: 'success', icon: 'check' },
          'done' => { name: 'success', icon: 'check' },
          'question' => { name: 'question', icon: 'help-circle' },
          'faq' => { name: 'question', icon: 'help-circle' },
          'help' => { name: 'question', icon: 'help-circle' },
          'danger' => { name: 'danger', icon: 'zap' },
          'error' => { name: 'danger', icon: 'zap' },
          'bug' => { name: 'bug', icon: 'bug' },
          'example' => { name: 'example', icon: 'list' },
          'quote' => { name: 'quote', icon: 'quote' }
        }

        callout_map[type] || { name: 'note', icon: 'pencil' }
      end
    end
  end
end
