module KMP3D
  module KMPImporter
    module_function

    Group = Struct.new(:range, :id)

    def import
      path = UI.openpanel("Select a file to import from.")
      Data.model.start_operation("Import KMP")
      @parser = BinaryParser.new(path)
      @gobj_ids = []
      read_header
      section_offsets = Array.new(@sections) { @parser.read_uint32 }
      section_offsets.each { |section_offset| read_group(section_offset) }
      section_offsets.each { |section_offset| read_section(section_offset) }
      Data.model.commit_operation
    end

    def read_header
      error("wrong file type") unless @parser.read(4) == "RKMD"
      @parser.read_uint32 # file length
      @sections = @parser.read_uint16
      @header_length = @parser.read_uint16
      @parser.read_uint32 # version
    end

    def read_group(section_offset)
      @parser.head = @header_length + section_offset
      section_id = @parser.read(4)
      entries = @parser.read_uint16
      @parser.read_uint16 # extra data
      case section_id
      when "ENPH" then @enph = Array.new(entries) { |i| import_group("ENPT",i) }
      when "ITPH" then @itph = Array.new(entries) { |i| import_group("ITPT",i) }
      when "CKPH" then @ckph = Array.new(entries) { |i| import_group("CKPT",i) }
      end
    end

    def read_section(section_offset)
      @parser.head = @header_length + section_offset
      section_id = @parser.read(4)
      entries = @parser.read_uint16
      @parser.read_uint16 # extra data
      type = Data.type_by_name(section_id)
      case section_id
      when "KTPT", "JGPT", "CNPT", "MSPT"
        entries.times { import_vector(type) }
      when "ENPT" then entries.times { |i| import_grouped(type, @enph, i) }
      when "ITPT" then entries.times { |i| import_grouped(type, @itph, i) }
      when "CKPT"
        type.set_kmp3d_points # prevents lookup every time a point is added
        entries.times { |i| import_ckpt(type, i) }
      when "GOBJ"
        entries.times { import_gobj(type) }
        existing_ids = type.table[1..-1].map { |t| t[0].to_i }
        (@gobj_ids.uniq - existing_ids).each { |id| type.table << [id.to_s] }
      when "POTI" then entries.times { |i| import_poti(type, i) }
      when "STGI" then import_stgi(type)
      end
    end

    def import_group(type_name, index)
      first_index = @parser.read_byte
      length = @parser.read_byte
      @parser.head += 6 # prev groups
      next_groups = Array.new(6) { @parser.read_byte }
      @parser.read_uint16 # padding
      type = Data.type_by_name(type_name)
      type.table[index] = [next_groups * ", "]
      return Group.new((first_index...length))
    end

    def get_group_index(groups, index)
      group = groups.select { |group| group.range === index }
      groups.index(group.first)
    end

    def import_settings(type)
      type.settings.map do |setting|
        case setting.input
        when :byte then @parser.read_byte
        when :float then @parser.read_float
        when :int16 then @parser.read_int16
        when :uint16 then @parser.read_uint16
        end
      end
    end

    def import_vector(type)
      position = @parser.read_vector3d
      rotation = @parser.read_rotation
      settings = import_settings(type)
      type.import(position, rotation, 0, settings)
    end

    def import_grouped(type, group_type, index)
      group = get_group_index(group_type, index)
      position = @parser.read_vector3d
      settings = import_settings(type)
      type.import(position, group, settings)
    end

    def import_ckpt(type, index)
      group = get_group_index(@ckph, index)
      position1 = @parser.read_vector2d
      position2 = @parser.read_vector2d
      respawn = @parser.read_byte
      checkpoint_type = @parser.read_byte
      @parser.read_byte # prev ID
      @parser.read_byte # next ID
      type.import(position1, position2, group, [respawn, checkpoint_type])
    end

    def import_gobj(type)
      id = @parser.read_uint16
      @parser.read_uint16 # padding
      position = @parser.read_vector3d
      rotation = @parser.read_rotation
      scale = @parser.read_vector3d
      settings = import_settings(type)
      @gobj_ids << id
      type.import(position, rotation, scale, id, settings)
    end

    def import_poti(type, index)
      points = @parser.read_uint16
      smooth = @parser.read_byte
      cyclic = @parser.read_byte
      type.table[index] = [smooth == 1, cyclic == 1]
      points.times do
        position = @parser.read_vector3d
        settings = import_settings(type)
        type.import(position, index, settings)
      end
    end

    def import_stgi(type)
      lap_count = @parser.read_byte
      pole_pos = @parser.read_byte
      distance = @parser.read_byte
      @parser.head += 6 # lens flare settings
      speed_mod = (@parser.next_bytes(2) + "\0\0").unpack("g")
      type.table[0] = [lap_count, pole_pos, distance, speed_mod]
    end

    def error(message)
      Data.model.abort_operation
      UI.messagebox("Error: #{message}!")
    end
  end
end