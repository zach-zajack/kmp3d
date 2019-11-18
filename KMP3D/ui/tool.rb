module KMP3D
  class Tool
    include HTMLHelpers
    include Callbacks
    include Observer

    def initialize
      @dlg = UI::WebDialog.new("KMP3D", false, "KMP3D")
      @ip = Sketchup::InputPoint.new
      @css = File.open("#{DIR}/css/default.css").read
      @scroll_types = 0
      @scroll_table = 0
      @type_index = 0
      add_callbacks
    end

    def refresh_html
      @type = Data.types[@type_index]
      @dlg.set_html(generate_head + generate_body)
      Data.set_layer_visible(@type.name) if tool_active?
    end

    private

    def group_index
      @dlg.get_element_value("currentGroup").to_i
    end

    def types
      sidenav(@type_index, "switchType", Data.types.map { |type| type.name })
    end

    def type_groups
      return "" unless @type.show_group?
      len = @type.groups
      size = [len + 1, 10].min
      sidenav(@type.group, "switchGroup", (0..len).map { |i| i == len ? \
        "#{@type.settings_name} Settings" : "#{@type.settings_names(i)}" })
    end

    def settings_button
      return "" unless @type.show_group?
      tag(:button, :onclick => callback("addGroup")) \
        { "Add #{@type.settings_name}" }
    end

    def generate_head
      tag(:head) do
        tag(:style) { @css }
      end
    end

    def generate_body
      tag(:body, {:onload => scroll_onload}) do
        tag(:div, :id => "types", :onscroll => on_scroll("types"),
          :class => "types") { types + type_groups + settings_button } + \
        tag(:div, :id => "table", :onscroll => on_scroll("table"),
          :class => "table") { @type.to_html }
      end
    end
  end
end
