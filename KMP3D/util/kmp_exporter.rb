module KMP3D
  module KMPExporter
    module_function

    def export
      path = UI.savepanel(
        "Select a file to export to.",  Data.model_dir, "#{Data.model_name}.kmp"
      )
      return if path.nil?
      @writer = BinaryWriter.new(path)
      write_header
      write_sections
      @writer.insert_uint32(4, @writer.head)
      @writer.write_to_file
    end

    def write_header
      @writer.write("RKMD")
      @writer.write_uint32(0) # skip file length for now
      @writer.write_uint16(15) # sections
      @writer.write_uint16(0x4C) # header length
      @writer.write_uint32(0x9D8) # file version
      @section_offsets_addr = @writer.head
      15.times { @writer.write_uint32(0) }
    end

    def write_sections
      write_section("KTPT") { |ent| export_ent(ent) }
      write_section("ENPT") { |ent| export_ent(ent) }
      write_group("ENPH", "ENPT")
      write_section("ITPT") { |ent| export_ent(ent) }
      write_group("ITPH", "ITPT")
      write_section("CKPT") { |ent| export_ckpt(ent) }
      write_group("CKPH", "CKPT")
      write_section("GOBJ") { |ent| export_gobj(ent) }
      write_section_poti
      write_section("AREA") { |ent| export_area(ent) }
      write_unhandled("CAME")
      write_section("JGPT") { |ent| export_ent(ent) }
      write_section("CNPT") { |ent| export_ent(ent) }
      write_section("MSPT") { |ent| export_ent(ent) }
      write_section_stgi
      Sketchup.status_text = "KMP3D: Finished exporting!"
      UI.beep
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
      @index = 0
      @type = Data.type_by_name(type_name)
      ents = Data.kmp3d_entities(type_name)
      write_section_offset
      write_section_header(type_name, ents.length, 0)
      ents.each do |ent|
        yield ent
        @index += 1
      end
    end

    def write_group(sect_name, type_name)
      Sketchup.status_text = "KMP3D: Exporting #{type_name}..."
      @type = Data.type_by_name(type_name)
      write_section_offset
      write_section_header(sect_name, @type.groups, 0)
      @type.groups.times do |i|
        # start
        @writer.write_byte(Data.entities_before_group(type_name, i).length)
        # length
        @writer.write_byte(Data.entities_in_group(type_name, i).length)
        prev_groups = (@type.prev_groups[i] + Array.new(6, 0xFF))[0, 6]
        next_groups = (@type.next_groups[i] + Array.new(6, 0xFF))[0, 6]
        prev_groups.each { |prev_group| @writer.write_byte(prev_group) }
        next_groups.each { |next_group| @writer.write_byte(next_group) }
        @writer.write_uint16(0) # padding
      end
    end

    def write_unhandled(type_name)
      Sketchup.status_text = "KMP3D: Exporting #{type_name}..."
      write_section_offset
      write_section_header(type_name, 0, 0)
    end

    def write_section_poti
      Sketchup.status_text = "KMP3D: Exporting POTI..."
      @type = Data.type_by_name("POTI")
      total_ents = Data.kmp3d_entities("POTI").length
      write_section_offset
      write_section_header("POTI", @type.groups, total_ents)
      @type.groups.times do |i|
        ents = Data.entities_in_group("POTI", i)
        @writer.write_uint16(ents.length)
        @writer.write_byte(@type.table[i+1][0] == "true" ? 1 : 0) # smooth
        @writer.write_byte(@type.table[i+1][1] == "true" ? 1 : 0) # cyclic
        ents.each { |ent| export_ent(ent) }
      end
    end

    def write_section_stgi
      Sketchup.status_text = "KMP3D: Exporting STGI..."
      write_section_offset
      write_section_header("STGI", 1, 0)
      settings = Data.type_by_name("STGI").table[1]
      @writer.write_byte(settings[0]) # lap count
      @writer.write_byte(settings[1]) # pole position
      @writer.write_byte(settings[2]) # driver distance
      @writer.write_byte(0) # flare
      @writer.write_byte(0)
      @writer.write_uint32(0xFFFFFF4B) # color
      @writer.write_byte(0)
      @writer.bytes += [settings[3].to_f].pack("g")[0,2]
    end

    def write_kmp_transform(ent)
      ent.kmp_transform.each { |v| @writer.write_float(v) }
    end

    def export_settings(ent, lower_range = 0, upper_range = -1)
      ent_settings = ent.kmp3d_settings[lower_range + 1..upper_range]
      type_settings = @type.settings[lower_range, ent_settings.length]
      type_settings.zip(ent_settings).each do |template, setting|
        setting = setting.hex if setting[0,2] == "0x"
        case template.input
        when :byte then @writer.write_byte(setting)
        when :float then @writer.write_float(setting)
        when :int16 then @writer.write_int16(setting)
        when :uint16 then @writer.write_uint16(setting)
        end
      end
    end

    def export_ent(ent)
      write_kmp_transform(ent)
      export_settings(ent)
    end

    def export_ckpt(ent)
      write_kmp_transform(ent)
      export_settings(ent)
      last_index = Data.entities_in_group("CKPT", ent.kmp3d_group).length - 1
      prev_index = @index == 0 ? 0xFF : @index - 1
      next_index = @index == last_index ? 0xFF : @index + 1
      @writer.write_byte(prev_index)
      @writer.write_byte(next_index)
    end

    def export_gobj(ent)
      @writer.write_uint16(Objects::LIST[ent.kmp3d_group])
      export_settings(ent, 0, 1)
      write_kmp_transform(ent)
      export_settings(ent, 1)
    end

    def export_area(ent)
      export_settings(ent, 0, 4)
      write_kmp_transform(ent)
      export_settings(ent, 4)
    end
  end
end
