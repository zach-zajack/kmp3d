module KMP3D
  class Type
    include HTMLHelpers, TypeHTML

    attr_reader :name, :external_settings, :settings
    attr_accessor :group, :table, :step

    Settings = Struct.new(:type, :input, :prompt, :default, :opts)

    def initialize
      @group = 0
      @step = 0
      if @external_settings # external settings deal with groups, mostly
        @table = Data.model.get_attribute("KMP3D", \
          type_name, [Array.new(@external_settings.length)])
        add_group if @table.length == 1
      end
    end

    def model
      Data.load_def("point")
    end

    def vector?
      false
    end

    def save_settings
      return unless @external_settings
      Data.model.set_attribute("KMP3D", type_name, @table)
    end

    def add_group
      return unless @external_settings
      @table << @external_settings.map { |s| s.default }
    end

    def component_settings
      "#{type_name}(#{@group},#{inputs[-1][1..-1] * ','}) "
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [[false] + @settings.map { |s| s.default }]
      Data.kmp3d_entities(type_name).each do |ent|
        settings = ent.kmp3d_settings(type_name)
        next unless settings[0] == @group.to_s # spot 1 is for the group number
        inputs << [Data.selection.include?(ent)] + settings[1..-1]
      end
      return inputs
    end

    def type_name
      self.class.name[7..-1]
    end

    def groups
      @external_settings.nil? ? 1 : @table.length - 1
    end

    def on_external_settings?
      @group == groups
    end

    def settings_name
      "Group"
    end

    def settings_names(i)
      "#{settings_name} #{i}"
    end

    def add_comp(comp)
      comp.name = "KMP3D " + component_settings
    end

    protected

    def entities_before_group
      ents_before_group = Data.kmp3d_entities(type_name).select do |ent|
        ent.kmp3d_settings(type_name)[0].to_i < @group
      end
      return ents_before_group.length
    end
  end
end
