module KMP3D
  module KMPExporter
    module_function

    def export
      path ||= UI.savepanel(
        "Select a file to export to.",
        Data.model_dir,
        "KMP|*.kmp||"
      )
      return if path.nil?

      path += ".kmp" if path[-3..-1] != "kmp"
      Data.reload(self)
      @writer = BinaryWriter.new(path)
      File.exist?(path) ? write_merged(path) : write_scratch
      @writer.insert_uint32(4, @writer.head)
      @writer.write_to_file
      Sketchup.status_text = "KMP3D: Finished exporting!"
      UI.beep
    end

    # export without writing to a file
    def test_export
      @writer = BinaryWriter.new
      write_scratch
      @writer.insert_uint32(4, @writer.head)
      return @writer.bytes
    end

    def write_scratch
      write_header
      Data.types[0...-1].each { |type| write_section_name(type.type_name) }
    end

    def write_merged(path)
      write_header
      @parser = BinaryParser.new(path)
      error("wrong file type") unless @parser.read(4) == "RKMD"
      @parser.read_uint32 # file length
      error("invalid number of sections") unless @parser.read_uint16 == 15
      header_length = @parser.read_uint16
      @parser.read_uint32 # version
      @section_offsets_addr = @parser.head
      @offsets = Array.new(15) { header_length + @parser.read_uint32 }
      15.times { |i| merge_section(i) }
    end

    def merge_section(n)
      @parser.head = @offsets[n]
      type = @parser.read(4)
      ents = Data.kmp3d_entities(type)
      return if %w[ENPH ITPH CKPH].include?(type)

      if ents != [] || type == "STGI"
        write_section_name(type)
      else
        write_old_section(type, n)
      end
    end

    def write_old_section(type, n)
      write_section_offset # write the new section offset
      @parser.head = @offsets[n]
      section_length = @offsets[n + 1] - @offsets[n]
      @writer.write(@parser.read(section_length))
      # write the header too!
      return unless %w[ENPT ITPT CKPT].include?(type)
      write_old_section(type.sub("PT", "PH"), n + 1)
    end

    def write_header
      @writer.write("RKMD")
      @writer.write_uint32(0) # skip file length for now
      @writer.write_uint16(15) # sections
      @writer.write_uint16(0x4C)
      @writer.write_uint32(0x9D8) # file version
      @section_offsets_addr = @writer.head
      15.times { @writer.write_uint32(0) }
    end

    def write_section_name(type)
      case type
      when "KTPT", "JGPT", "CNPT", "MSPT"
        write_section(type) { |ent| export_ent(ent) }
      when "ENPT"
        write_section("ENPT") { |ent| export_ent(ent) }
        write_group("ENPH", "ENPT")
      when "ITPT"
        write_section("ITPT") { |ent| export_ent(ent) }
        write_group("ITPH", "ITPT")
      when "CKPT"
        write_section_ckpt
        write_group("CKPH", "CKPT")
      when "GOBJ" then write_section("GOBJ") { |ent| export_gobj(ent) }
      when "POTI" then write_section_poti
      when "AREA" then write_section("AREA") { |ent| export_area(ent) }
      when "CAME" then write_section("CAME") { |ent| export_came(ent) }
      when "STGI" then write_section_stgi
      end
    end

    def write_section_offset
      @writer.insert_uint32(@section_offsets_addr, @writer.head - 0x4C)
      @section_offsets_addr += 4
    end

    def write_section_header(type_name, ents_count, extra_value)
      @writer.write(type_name)
      @writer.write_uint16(ents_count)
      @writer.write_uint16(extra_value)
    end

    def write_section(type_name)
      Sketchup.status_text = "KMP3D: Exporting #{type_name}..."
      @type = Data.type_by_typename(type_name)
      ents = Data.kmp3d_entities(type_name)
      write_section_offset
      write_section_header(type_name, ents.length, 0)
      ents.each { |ent| yield ent }
    end

    def write_group(sect_name, type_name)
      Sketchup.status_text = "KMP3D: Exporting #{type_name}..."
      @type = Data.type_by_typename(type_name)
      write_section_offset
      write_section_header(sect_name, @type.groups, 0)
      @type.groups.times do |i|
        # start
        @writer.write_byte(Data.entities_before_group(type_name, i).length)
        # length
        @writer.write_byte(Data.entities_in_group(type_name, i).length)
        @type.generate_next_groups_table
        prev_groups = (@type.prev_groups(i) + Array.new(6, 0xFF))[0, 6]
        next_groups = (@type.next_groups(i) + Array.new(6, 0xFF))[0, 6]
        prev_groups.each { |prev_group| @writer.write_byte(prev_group) }
        next_groups.each { |next_group| @writer.write_byte(next_group) }
        @writer.write_uint16(0) # padding
      end
    end

    def write_section_ckpt
      Sketchup.status_text = "KMP3D: Exporting CKPT..."
      @type = Data.type_by_typename("CKPT")
      total_ents = Data.kmp3d_entities("CKPT").length
      write_section_offset
      write_section_header("CKPT", total_ents, 0)
      index = 0
      prev_nil_index = 0
      next_nil_index = -1
      @type.groups.times do |i|
        ents = Data.entities_in_group("CKPT", i)
        next_nil_index += ents.length
        ents.each do |ent|
          write_kmp_transform(ent)
          export_ent_settings(ent)
          @writer.write_byte(index == prev_nil_index ? 0xFF : index - 1)
          @writer.write_byte(index == next_nil_index ? 0xFF : index + 1)
          index += 1
        end
        prev_nil_index += ents.length
      end
    end

    def write_section_poti
      Sketchup.status_text = "KMP3D: Exporting POTI..."
      @type = Data.type_by_typename("POTI")
      total_ents = Data.kmp3d_entities("POTI").length
      write_section_offset
      write_section_header("POTI", @type.groups, total_ents)
      @type.groups.times do |i|
        ents = Data.entities_in_group("POTI", i)
        @writer.write_uint16(ents.length)
        @writer.write_byte(@type.table[i + 1][0]) # smooth
        @writer.write_byte(@type.table[i + 1][1]) # cyclic
        ents.each { |ent| export_ent(ent) }
      end
    end

    def write_kmp_transform(ent)
      ent.kmp_transform.each { |v| @writer.write_float(v) }
    end

    def export_ent_settings(ent, lower_range=0, upper_range=-1)
      ent_settings = ent.kmp3d_settings[lower_range + 1..upper_range]
      type_settings = @type.settings[lower_range, ent_settings.length]
      export_settings(ent_settings, type_settings)
    end

    def export_settings(ent_settings, type_settings)
      type_settings.zip(ent_settings).each do |template, setting|
        case template.input
        when :byte then @writer.write_byte(setting)
        when :float then @writer.write_float(setting)
        when :int16 then @writer.write_int16(setting)
        when :uint16 then @writer.write_uint16(setting)
        when :uint32 then @writer.write_uint32(setting)
        end
      end
    end

    def export_ent(ent)
      write_kmp_transform(ent)
      export_ent_settings(ent)
    end

    def export_gobj(ent)
      @writer.write_uint16(Objects::LIST[ent.kmp3d_group].id)
      export_ent_settings(ent, 0, 1)
      write_kmp_transform(ent)
      export_ent_settings(ent, 1)
    end

    def export_area(ent)
      export_ent_settings(ent, 0, 4)
      write_kmp_transform(ent)
      export_ent_settings(ent, 4)
    end

    def export_came(ent)
      settings = ent.kmp3d_settings[1..-1]
      type_index = ent.kmp3d_group.to_i
      type = CAME::CAMTYPES[type_index]
      @writer.write_byte(type_index)
      export_ent_settings(ent, 0, 8)
      write_came_position(ent, type, settings)
      @writer.write_csv_float(settings[9]) # rotation
      @writer.write_float(settings[10]) # zoom start
      @writer.write_float(settings[11]) # zoom end
      write_came_rails(ent, type, settings)
      @writer.write_float(settings[14]) # time
    end

    def write_came_position(ent, type, settings)
      case type.model
      when :point then @writer.write_position(ent.transformation.origin)
      when :rails then @writer.write_csv_float(settings[8])
      when :both
        ents = ent.definition.entities
        comp = ents.select { |e| e.typename == "ComponentInstance" }
        @writer.write_position(comp.first.transformation.origin)
      end
    end

    def write_came_rails(ent, type, settings)
      if type.model == :point
        @writer.write_csv_float(settings[12])
        @writer.write_csv_float(settings[13])
      else
        ents = ent.definition.entities
        line = ents.select { |e| e.typename == "ConstructionLine" }.first
        @writer.write_position(line.start)
        @writer.write_position(line.end)
      end
    end

    def write_section_stgi
      @type = Data.type_by_typename("STGI")
      Sketchup.status_text = "KMP3D: Exporting STGI..."
      write_section_offset
      write_section_header("STGI", 1, 0)
      settings = @type.table[1]
      export_settings(settings[0...6], @type.external_settings[0...6])
      @writer.write_byte(0)
      speed_mod = settings[6].to_f
      @writer.bytes += speed_mod == 1.0 ? "\0\0" : [speed_mod].pack("g")[0, 2]
    end

    def error(message)
      UI.messagebox("KMP3D: Cannot merge file, #{message}")
      write_scratch
    end
  end
end
