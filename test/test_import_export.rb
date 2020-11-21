module KMP3D
  class TestImportExport < KMP3DTest
    include KMP

    def initialize
      super
      Dir["#{DIR}/test/kmps/*.kmp"].each do |path|
        start_test
        Data.entities.each { |ent| ent.erase! }

        KMPImporter.import(path)
        @old_parser = BinaryParser.new(path)

        new_bytes = KMPExporter.test_export
        @new_parser = BinaryParser.new
        @new_parser.bytes = new_bytes

        compare_header
        15.times { compare_section }
        puts "Done comparing #{path}"
        print_results
      end
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
      entries = assert_match(:uint16, "Entry count")
      assert_match(:uint16, "Additional value")
      if section == "POTI"
        entries.times do
          poti_entries = assert_match(:uint16, "POTI Entry count")
          assert_match(:byte, "POTI Route Setting 1")
          assert_match(:byte, "POTI Route Setting 2")
          poti_entries.times { compare_section_entries("POTI") }
        end
      else
        entries.times { compare_section_entries(section) }
      end
    end

    private

    def compare_section_entries(sect)
      SECTIONS[sect].each { |s| assert_match(s.datatype, "#{sect} #{s.msg}") }
    end

    def assert_match(datatype, msg)
      old, new = get_data_comparison(datatype)
      assert_equal(new, old, msg)
      return old
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
