module KMP3D
  module HTMLHelpers
    def tag(name, attributes = {})
      content = "#{yield}</#{name}>" if block_given?
      return "<#{name}#{attributes_to_html(attributes)}>#{content}"
    end

    def sidenav(id, index, callback, options = [])
      tag(:div, :class => "sidenav") do
        i = 0
        options.map do |option|
          opts = {:value => i, :onmousedown => "this.id='#{id}';#{callback}"}
          opts.merge!(:id => "#{id}Old", :class => "selected") if i == index
          i += 1
          tag(:button, opts) { option }
        end
      end
    end

    def select(selected_id, attributes = {}, options = [])
      tag(:select, attributes) do
        i = 0
        options.map do |option|
          opts = {:value => i}
          opts[:selected] = "selected" if i == selected_id
          i += 1
          tag(:option, opts) { option }
        end
      end
    end

    def checkbox(label, attributes = {}, checked = false)
      attributes[:type] = "checkbox"
      attributes[:checked] = "true" if checked
      tag(:label) { tag(:input, attributes) + label }
    end

    def callback(name = "", args = "")
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
