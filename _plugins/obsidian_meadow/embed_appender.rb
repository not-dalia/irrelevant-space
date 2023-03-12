require 'nokogiri'

module Jekyll
  module ObsidianMeadow
    class EmbedAppender
      def initialize(site)
        @site = site
        @supported_docs = ObsidianMeadow.supported_docs
      end

      def append_embeds
        @supported_docs.docs.each do |doc|
          append_embed_to_doc(doc.doc)
        end
      end

      def append_embed_to_doc(doc)
        html_doc = Nokogiri::HTML(doc.output)
        html_doc.css('a.embed-link').each do |l|
          if l['data-embed-url']
            embed_url = l['data-embed-url']
            embed_doc = @supported_docs.docs.find { |d| d.doc.url == embed_url }
            embed_asset = @supported_docs.assets.find { |a, val| val['file'].url == embed_url }
            if embed_doc
              embed_content = embed_doc.doc.content
              embed_html_doc = Nokogiri::HTML(embed_content)
              # create element for embed
              embed_element = Nokogiri::XML::Node.new('div', html_doc)
              embed_element['class'] = 'meadow-embed'
              if l['data-embed-fragment'] && l['data-embed-fragment'] != ''
                keep_adding = false
                header_level = 0
                embed_html_doc.css('body').children.each do |child|
                  if child['id'] == l['data-embed-fragment']
                    embed_element.add_child(child)
                    keep_adding = true
                    header_level = child.name[1].to_i if  child.name[0] == 'h'
                  elsif keep_adding && header_level > 0
                    if child.name[0] == 'h'
                      if child.name[1].to_i <= header_level
                        keep_adding = false
                      else
                        embed_element.add_child(child)
                      end
                    else
                      embed_element.add_child(child)
                    end
                  elsif keep_adding && header_level == 0
                    embed_element.add_child(child)
                    keep_adding = false
                  end
                end
              else
                embed_html_doc.css('body').children.each do |child|
                  embed_element.add_child(child)
                end
              end
              # fint any self referencing links and update them
              embed_element.css('a').each do |a|
                if a['href'] && a['href'].start_with?('#')
                  a['href'] = "#{embed_url}#{a['href']}"
                end
              end
              # find footnotes in embed_element and add them to the end of the document
              ol_element = Nokogiri::XML::Node.new('ol', html_doc)
              ol_element['class'] = 'footnotes'
              embed_element.css('.footnote').each do |footnote_ref|
                footnote_id = footnote_ref['href']
                Jekyll.logger.info("EmbedAppender: footnote_id: #{footnote_id}")
                footnote = embed_html_doc.css(footnote_id.gsub(':', '\\:')).first if footnote_id
                # TODO: fix footnote ref id
                if footnote
                  footnote_ref['href'] = "#{embed_url}#{footnote_ref['href']}"
                  footnote['id'] = "#{footnote['id']}-#{embed_url}"
                  footnote['class'] = "#{footnote['class']} footnote-embed"
                  footnote.at_css('a')['href'] = "#{embed_url}#{footnote.at_css('a')['href']}" if footnote.at_css('a')
                  footnote['data-embed-url'] = embed_url
                  footnote['data-embed-fragment'] = l['data-embed-fragment']
                  footnote['data-embed-fragment'] = '' if footnote['data-embed-fragment'] == embed_url
                  # create ol element
                  ol_element.add_child(footnote)
                end
              end
              embed_element.add_child(ol_element)
              l.add_next_sibling(embed_element)
            elsif embed_asset
              # create element for embed
              case embed_asset[1]['type']
              when 'image'
                embed_element = Nokogiri::XML::Node.new('img', html_doc)
                embed_element['src'] = embed_asset[1]['file'].url
                embed_element['alt'] = "Image: #{embed_asset[1]['file'].basename}"
                data_config = l.parent['data-config']
                if data_config
                  data_config = data_config.split('x')
                  embed_element['width'] = data_config[0] if data_config[0]
                  embed_element['height'] = data_config[1] if data_config[1]
                end
              when 'video'
                embed_element = Nokogiri::XML::Node.new('video', html_doc)
                embed_element['src'] = embed_asset[1]['file'].url
                embed_element['controls'] = 'controls'
              when 'audio'
                embed_element = Nokogiri::XML::Node.new('audio', html_doc)
                embed_element['src'] = embed_asset[1]['file'].url
                embed_element['controls'] = 'controls'
              when 'pdf'
                embed_element = Nokogiri::XML::Node.new('embed', html_doc)
                embed_element['src'] = embed_asset[1]['file'].url
              end
              wrapper_embed_element = Nokogiri::XML::Node.new('div', html_doc)
              wrapper_embed_element['class'] = 'asset-embed meadow-embed'
              wrapper_embed_element.add_child(embed_element)
              l.parent['class'] = l.parent['class'] + ' wikilink-asset-embed'
              l.add_next_sibling(wrapper_embed_element)
            end
          end
        end
        doc.output = html_doc.inner_html
      end
    end
  end
end
