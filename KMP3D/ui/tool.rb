module KMP3D
  class Tool
    include HTMLHelpers
    include Callbacks
    include Observer

    def initialize
      @dlg = UI::WebDialog.new("KMP3D", false, "KMP3D")
      @ip = Sketchup::InputPoint.new
      @css = File.open("#{DIR}/css/default.css").read
      @scroll = 0
      add_callbacks
    end

    def type
      Data.types[type_index]
    end

    def type_index
      @dlg.get_element_value("currentType").to_i
    end

    def refresh_html
      @dlg.set_html(generate_head + generate_body)
    end

    private

    def group_index
      @dlg.get_element_value("currentGroup").to_i
    end

    def types
      select(type_index,
        :id => "currentType",
        :size => 10,
        :onchange => callback("refresh"),
        *Data.types.map { |type| type.name }
      )
    end

    def type_groups
      return "" unless type.show_group?
      len = type.groups
      size = [len + 1, 10].min
      select(type.group,
        :id => "currentGroup",
        :size => size,
        :onchange => callback("setGroup"),
        *(0..len).map { |i| i == len ? \
          "#{type.settings_name} Settings" : "#{type.settings_names(i)}" }
      )
    end

    def settings_button
      return "" unless type.show_group?
      tag(:button, :onclick => callback("addGroup")) \
        { "Add #{type.settings_name}" }
    end

    def generate_head
      tag(:head) do
        tag(:style) { @css }
      end
    end

    def generate_body
      tag(:body, \
        :onload => "document.getElementById('table').scrollTop=#{@scroll}") do
        tag(:div, {:id => "table", :onscroll => on_scroll,
          :class => "table"}) { type.to_html } + \
        tag(:div, {:class => "types"}) { types + type_groups + settings_button }
      end
    end
  end
end
