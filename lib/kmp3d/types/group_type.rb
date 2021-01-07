module KMP3D
  class GroupType < Type
    attr_reader :external_settings
    attr_accessor :table

    def initialize
      super
      return unless @external_settings
      @table = Data.model.get_attribute("KMP3D", type_name, \
                                        [Array.new(@external_settings.length)])
      add_group(true)
    end

    def save_settings
      Data.model.set_attribute("KMP3D", type_name, @table)
    end

    def add_group(init=false)
      @table << @external_settings.map { |s| s.default } if !init || num_groups == 0
    end

    def num_groups
      @table.length - 1
    end

    def on_external_settings?
      @group == num_groups
    end

    def group_options
      settings = (0...num_groups).map { |i| "#{settings_name} #{group_id(i)}" }
      settings << "#{settings_name} Settings"
      sn = sidenav(@group, "switchGroup", settings)
      sn + tag(:button, :onclick => callback("addGroup")) do
        "Add #{settings_name}"
      end
    end

    def generate_next_groups_table
      @next_groups_table = table[1..-1].map do |row|
        row[0].split(",").map { |i| i.to_i }
      end
    end

    def next_groups(row)
      @next_groups_table[row]
    end

    def prev_groups(row)
      @next_groups_table.each do |next_grps|
        next unless next_grps.include?(row)
        return num_groups.times.select { |i| @next_groups_table[i] == next_grps }
      end
      return [] # if no groups found
    end
  end
end
