module KMP3D
  class Type
    include Table
    include HTMLHelpers

    attr_reader :name, :settings
    attr_accessor :group, :step

    Settings = Struct.new(:type, :input, :prompt, :default, :opts)

    def initialize
      @group = 0
      @step = 0
    end

    def model
      Data.load_def("point")
    end

    def vector?
      false
    end

    def hybrid?
      false
    end

    def hide_point?
      false
    end

    def sequential_id?
      true
    end

    def draw_connected_points(view, pos, selection=false)
    end

    def save_settings
    end

    def add_group(_init=false)
    end

    def component_settings
      "#{type_name}(#{group_id(@group)}|#{inputs[-1][2..-1] * '|'}) "
    end

    def table_helper_text
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [[-1, false] + @settings.map { |s| s.default }]
      Data.entities_in_group(type_name, group_id(@group)).each do |ent|
        id = ent.kmp3d_id(type_name)
        selected = Data.selection.include?(ent)
        inputs << [id, selected] + ent.kmp3d_settings[1..-1]
      end
      return inputs
    end

    def group_options
      ""
    end

    def linked_types
      []
    end

    def group_id(i)
      i
    end

    def select_point(ent)
    end

    def update_setting(ent, value, col)
      ent.edit_setting(col.to_i + 1, value)
    end

    def update_group(value, row, col)
      @table[row.to_i + 1][col.to_i] = value
    end

    def type_name
      self.class.name[7..-1]
    end

    def groups
      1
    end

    def on_external_settings?
      false
    end

    def settings_name
      "Group"
    end

    def add_comp(comp)
      comp.name = "KMP3D " + component_settings
      return comp
    end
  end
end
