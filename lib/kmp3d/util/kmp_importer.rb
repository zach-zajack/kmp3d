module KMP3D
  module KMPImporter
    module_function

    Group = Struct.new(:range, :id)

    def import(path=nil)
      path ||= UI.openpanel(
        "Select a file to import from.", Data.model_dir,
        "KMP|*.kmp|All files|*||"
      )
      return if path.nil?

      ask_kcl_import(path)
      Data.model.start_operation("Import KMP", true)
      @parser = BinaryParser.new(path)
      @gobj_ids = []
      read_header
      section_offsets = Array.new(@sections) { @parser.read_uint32 }
      section_offsets.each { |section_offset| read_group(section_offset) }
      section_offsets.each { |section_offset| read_section(section_offset) }
      Data.model.commit_operation
      Sketchup.status_text = "KMP3D: Finished importing!"
      UI.beep
    end

    def ask_kcl_import(path)
      kcl_path = File.dirname(path) + "/course.kcl"
      return unless File.exist?(kcl_path)

      msg = "A course.kcl file was found in the directory of the KMP file." \
            " Would you like to import it as well?"
      KCLImporter.import(kcl_path) if UI.messagebox(msg, MB_YESNO) == IDYES
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
      ents = @parser.read_uint16
      @parser.read_uint16 # extra data
      case section_id
      when "ENPH" then @enph = Array.new(ents) { |i| import_group("ENPT", i) }
      when "ITPH" then @itph = Array.new(ents) { |i| import_group("ITPT", i) }
      when "CKPH" then @ckph = Array.new(ents) { |i| import_group("CKPT", i) }
      end
    end

    def read_section(section_offset)
      @parser.head = @header_length + section_offset
      section_id = @parser.read(4)
      entries = @parser.read_uint16
      extra_data1 = @parser.read_byte
      extra_data2 = @parser.read_byte
      @type = Data.type_by_typename(section_id)
      Sketchup.status_text = "KMP3D: Importing #{section_id}..."
      case section_id
      when "KTPT", "JGPT", "CNPT", "MSPT"
        entries.times { import_vector }
      when "ENPT" then entries.times { |i| import_point(@enph, i) }
      when "ITPT" then entries.times { |i| import_point(@itph, i) }
      when "CKPT"
        @type.set_enpt # prevents lookup every time a point is added
        entries.times { |i| import_ckpt(i) }
      when "GOBJ"
        entries.times { import_gobj }
        existing_ids = @type.table[1..-1].map { |t| t[0] }
        (@gobj_ids.uniq - existing_ids).each do |id|
          @type.table << [id, Data.load_obj(id)]
        end
      when "POTI" then entries.times { |i| import_poti(i) }
      when "AREA" then entries.times { import_area }
      when "CAME"
        @type.op_cam_index  = extra_data1
        @type.vid_cam_index = extra_data2
        entries.times { import_came }
      when "STGI" then import_stgi
      end
    end

    def import_group(type_name, index)
      first_index = @parser.read_byte
      length = @parser.read_byte
      @parser.head += 6 # prev groups
      next_groups = Array.new(6) { @parser.read_byte }
      next_groups.delete(255)
      @parser.read_uint16 # padding
      @type = Data.type_by_typename(type_name)
      @type.table[index + 1] = [next_groups * ", "]
      return Group.new((first_index...first_index + length))
    end

    def get_group_index(groups, index)
      group = groups.select { |group| group.range === index }
      groups.index(group.first)
    end

    def import_settings(settings)
      settings.map do |setting|
        hexify = setting.default.to_s[0, 2] == "0x"
        case setting.input
        when :byte then format(@parser.read_byte, hexify)
        when :float then @parser.read_float
        when :int16 then format(@parser.read_int16, hexify)
        when :uint16 then format(@parser.read_uint16, hexify)
        when :uint32 then format(@parser.read_uint32, hexify)
        end
      end
    end

    def format(num, hexify)
      hexify && num >= 10 ? "0x" + ("%x" % num).upcase : num
    end

    def import_vector
      position = @parser.read_position3d
      rotation = @parser.read_rotation
      settings = import_settings(@type.settings)
      @type.import(position, rotation, 0, settings)
    end

    def import_point(group_type, group_index)
      group = get_group_index(group_type, group_index)
      position = @parser.read_position3d
      settings = import_settings(@type.settings)
      @type.import(position, group, settings)
    end

    def import_position_stored(settings)
      x, y, z = Array.new(3) { @parser.read_float }
      settings << [x, y, z].join(", ")
      return [x.m, -z.m, y.m]
    end

    def import_ckpt(index)
      group = get_group_index(@ckph, index)
      position1 = @parser.read_position2d
      position2 = @parser.read_position2d
      respawn = @parser.read_byte
      type = @parser.read_byte
      checkpoint_type = format(type, type == 0xFF)
      @parser.read_byte # prev ID
      @parser.read_byte # next ID
      @type.import(position1, position2, group, [respawn, checkpoint_type])
    end

    def import_gobj
      id = Objects.name_from_id(@parser.read_uint16)
      settings = import_settings(@type.settings[0...1])
      position = @parser.read_position3d
      rotation = @parser.read_rotation
      scale = @parser.read_scale
      settings += import_settings(@type.settings[1..-1])
      @gobj_ids << id
      @type.import(position, rotation, scale, id, settings)
    end

    def import_poti(index)
      points = @parser.read_uint16
      smooth = @parser.read_byte
      cyclic = @parser.read_byte
      @type.table[index + 1] = [smooth, cyclic]
      points.times do
        position = @parser.read_position3d
        settings = import_settings(@type.settings)
        @type.import(position, index, settings)
      end
    end

    def import_area
      settings = import_settings(@type.settings[0...4])
      position = @parser.read_position3d
      rotation = @parser.read_rotation
      scale = @parser.read_scale
      settings += import_settings(@type.settings[4..-1])
      @type.import(position, rotation, scale, 0, settings)
    end

    def import_came
      type_index = @parser.read_byte
      settings = import_settings(@type.settings[0...8])
      position = import_position_stored(settings)
      import_position_stored(settings) # rotation
      settings << @parser.read_float # zoom start
      settings << @parser.read_float # zoom end
      rail_start = import_position_stored(settings)
      rail_end   = import_position_stored(settings)
      settings << @parser.read_float # time
      @type.import(position, rail_start, rail_end, type_index, settings)
    end

    def import_stgi
      settings = import_settings(@type.external_settings[0...6])
      @parser.read_byte # ignore first byte for speed mod
      speed_mod = (@parser.next_bytes(2) + "\0\0").unpack("F").first
      speed_mod = 1.0 if speed_mod == 0.0 # backwards compatibility
      @type.table[1] = settings + [speed_mod]
    end

    def error(message)
      Data.model.abort_operation
      raise "KMP3D: #{message}"
      UI.messagebox("Error: #{message}!")
    end
  end
end
