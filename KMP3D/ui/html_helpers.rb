module KMP3D
  module HTMLHelpers
    def tag(name, attributes = {})
      content = "#{yield}</#{name}>" if block_given?
      return "<#{name}#{attributes_to_html(attributes)}>#{content}"
    end

    def select(selected_id, attributes = {}, *options)
      tag(:select, attributes) do
        i = -1
        options.map do |option|
          i += 1
          opts = {:value => i.to_s}
          opts[:selected] = "selected" if i == selected_id
          tag(:option, opts) { option }
        end
      end
    end

    def callback(name, args = "")
      "window.location='skp:#{name}@#{args}';" \
      "window.location='skp:refresh';"
    end

    def on_scroll
      "window.location='skp:scroll@'+document.getElementById('table').scrollTop"
    end

    private

    def attributes_to_html(attributes)
      attributes.map { |k, v| " #{k}=#{v.inspect}" } * ""
    end
  end
end
