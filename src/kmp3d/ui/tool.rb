module KMP3D
  class Tool
    include Observer
    include Callbacks
    include HTMLHelpers

    def initialize
      @dlg = UI::WebDialog.new("KMP3D", false, "KMP3D")
      @ip = Sketchup::InputPoint.new
      @css = File.open("#{DIR}/app/css/default.css").read
      @scroll_types = 0
      @scroll_table = 0
      @type_index = 0
      @prev_selection = []
      add_callbacks
    end

    def refresh_html
      @type = Data.types[@type_index]
      Data.set_layer_visible(@type.name)
      @dlg.set_html(generate_head + generate_body(@type.to_html))
    end

    def update_row(ent)
      refresh_html if ent.deleted?
      row_id = ent.kmp3d_id(@type.type_name)
      return if row_id.nil? || @type.on_external_settings?

      selected = Data.selection.include?(ent)
      js = toggle_select(row_id, selected)
      id = 0
      ent.kmp3d_settings[1..-1].each do |setting|
        js << "document.getElementById('#{row_id},#{id}').value='#{setting}';"
        id += 1
      end
      @dlg.execute_script(js)
    end

    def add_row(ent)
      @dlg.execute_script(append_row_html(@type.row_html(ent)))
    end

    private

    def group_index
      @dlg.get_element_value("currentGroup").to_i
    end

    def types
      sidenav(@type_index, "switchType", Data.types.map { |type| type.name })
    end

    def linked_types
      checkboxes = @type.linked_types.map do |type|
        attribs = {:id => type, :onchange => callback("toggleLayer", type)}
        checkbox(type, attribs, Data.layers[type].visible?)
      end
      checkboxes * br
    end

    def generate_head
      tag(:head) do
        tag(:meta, :"http-equiv" => "X-UA-Compatible", :content => "IE=edge") +
          tag(:style) { @css }
      end
    end

    def generate_body(table_html)
      tag(:body, {:onload => scroll_onload}) do
        html = tag(:div, :id => "type", :onscroll => on_scroll("types")) do
          types + @type.group_options + linked_types
        end
        html + tag(:div, :id => "table", :onscroll => on_scroll("table")) do
          table_html
        end
      end
    end
  end
end
