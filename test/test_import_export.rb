module KMP3D
  class TestImportExport < KMP3DTest
    def initialize(path)
      super
      puts "Rebuilding #{File.basename(path)}..."
      Data.entities.each { |ent| ent.erase! if ent.kmp3d_object? }

      start = Time.now
      KMPImporter.import(path)
      @old_parser = BinaryParser.new(path)
      puts "Import time: #{Time.now - start}"

      start = Time.now
      new_bytes = KMPExporter.test_export
      @new_parser = BinaryParser.new
      @new_parser.bytes = new_bytes
      puts "Export time: #{Time.now - start}"

      compare_header
      15.times { compare_section }
      print_results
    end

    def compare_header
      assert_match(:magic, "File magic")
      assert_match(:uint32, "File length")
      assert_match(:uint16, "Section count")
      assert_match(:uint16, "Header length")
      assert_match(:uint32, "KMP version")
      15.times { |i| assert_match(:uint32, "Section offset no. #{i}") }
    end

    def compare_section
      section = assert_match(:magic, "Section ID")
      entries = assert_match(:uint16, "#{section} Entry count")
      assert_match(:byte, "#{section} Additional value 1")
      assert_match(:byte, "#{section} Additional value 2")
      if section == "POTI"
        entries.times do |i|
          poti_entries = assert_match(:uint16, "POTI #{i} Entry count")
          assert_match(:byte, "POTI #{i} Route Setting 1")
          assert_match(:byte, "POTI #{i} Route Setting 2")
          poti_entries.times { |j| compare_sect_entries("POTI", "#{i},#{j}") }
        end
      else
        entries.times { |i| compare_sect_entries(section, i) }
      end
    end

    private

    def compare_sect_entries(sect, id)
      KMP3D::KMP::SECTIONS[sect].each do |s|
        if s.datatype == :rotation
          assert_rotation("#{sect} #{id}")
        else
          assert_match(s.datatype, "#{sect} #{id} #{s.msg}")
        end
      end
    end

    def assert_match(datatype, msg)
      old, new = get_data_comparison(datatype)
      assert_equal(new, old, msg)
      return old
    end

    def assert_rotation(msg)
      old = @old_parser.read_rotation
      new = @new_parser.read_rotation
      match = KMP3D::KMPMath.euler_equal?(old, new)
      # approximate for readability
      old.map! { |o| o.radians.to_i }
      new.map! { |n| n.radians.to_i }
      assert(match, "#{msg} Rotation mismatch: #{old} != #{new}")
    end

    def get_data_comparison(datatype)
      case datatype
      when :magic  then [@old_parser.read(4),     @new_parser.read(4)]
      when :byte   then [@old_parser.read_byte,   @new_parser.read_byte]
      when :uint16 then [@old_parser.read_uint16, @new_parser.read_uint16]
      when :int16  then [@old_parser.read_int16,  @new_parser.read_int16]
      when :uint32 then [@old_parser.read_uint32, @new_parser.read_uint32]
      when :float  then [@old_parser.read_float,  @new_parser.read_float]
      end
    end
  end
end
