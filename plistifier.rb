# Borrowed and modified from:
#  http://github.com/jeena/plistifier

module ActionController
  class Base
    def render_with_plist(options = nil, extra_options = {}, &block)
      
      plist = options.delete(:plist) if options.is_a?(Hash)
      
      if plist
        
        response.headers["Location"] = options[:location] unless options[:location].blank?
        options[:content_type] ||= Mime::PLIST
        options[:disposition] ||= "inline"
        
        if options[:plist_filename].blank?
          if plist.is_a? Array
            options[:plist_filename] = plist.first.class.name.pluralize + ".plist"
          elsif plist.respond_to?(:object_id)
            options[:plist_filename] = "#{plist.class.name}-#{plist.object_id}.plist"
          else
            options[:plist_filename] = "#{plist.class.name}-data.plist"
          end
        end
        
        format = (params[:xml] == "true") ? CFPropertyList::List::FORMAT_XML : CFPropertyList::List::FORMAT_BINARY
        data = plist.to_plist :plist_format => format, :convert_unknown_to_string => true, :converter_method => :to_hash
        send_data(
          data,
          :type => options[:content_type], 
          :filename => options[:plist_filename], 
          :disposition => options[:disposition],
          :status => options[:status]
        )
        
      else
        render_without_plist(options, extra_options, &block) 
      end
    end
    
    alias_method_chain :render, :plist
  end
end
