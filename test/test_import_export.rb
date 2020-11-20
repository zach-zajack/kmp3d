module KMP3D
  class TestImportExport < KMP3DTest
    Setting = Struct.new(:datatype, :msg)

    POSITION = [
      Setting.new(:float, "Position X"),
      Setting.new(:float, "Position Y"),
      Setting.new(:float, "Position Z")
    ]

    ROTATION = [
      Setting.new(:float, "Rotation X"),
      Setting.new(:float, "Rotation Y"),
      Setting.new(:float, "Rotation Z")
    ]

    SCALE = [
      Setting.new(:float, "Scale X"),
      Setting.new(:float, "Scale Y"),
      Setting.new(:float, "Scale Z")
    ]

    GROUP = [
      Setting.new(:byte, "Group start"),
      Setting.new(:byte, "Group length"),
      *Array.new(6) { |i| Setting.new(:byte, "Prev group #{i}") },
      *Array.new(6) { |i| Setting.new(:byte, "Next group #{i}") },
      Setting.new(:uint16, "Padding")
    ]

    SECTIONS = {
      "KTPT" => [
        *POSITION,
        *ROTATION,
        Setting.new(:int16, "Index"),
        Setting.new(:uint16, "Padding")
      ],
      "ENPT" => [
        *POSITION,
        Setting.new(:float, "Size"),
        Setting.new(:uint16, "Setting 1"),
        Setting.new(:byte, "Setting 2"),
        Setting.new(:byte, "Setting 3")
      ],
      "ENPH" => GROUP,
      "ITPT" => [
        *POSITION,
        Setting.new(:float, "Size"),
        Setting.new(:uint16, "Setting 1"),
        Setting.new(:uint16, "Setting 2")
      ],
      "ITPH" => GROUP,
      "CKPT" => [
        Setting.new(:float, "X1"),
        Setting.new(:float, "Y1"),
        Setting.new(:float, "X2"),
        Setting.new(:float, "Y2"),
        Setting.new(:byte, "Respawn"),
        Setting.new(:byte, "Type"),
        Setting.new(:byte, "Prev"),
        Setting.new(:byte, "Next")
      ],
      "CKPH" => GROUP,
      "GOBJ" => [
        Setting.new(:uint16, "ID"),
        Setting.new(:uint16, "Padding"),
        *POSITION,
        *ROTATION,
        *SCALE,
        Setting.new(:uint16, "Route"),
        Setting.new(:uint16, "Setting 1"),
        Setting.new(:uint16, "Setting 2"),
        Setting.new(:uint16, "Setting 3"),
        Setting.new(:uint16, "Setting 4"),
        Setting.new(:uint16, "Setting 5"),
        Setting.new(:uint16, "Setting 6"),
        Setting.new(:uint16, "Setting 7"),
        Setting.new(:uint16, "Setting 8"),
        Setting.new(:uint16, "Flags")
      ],
      "POTI" => [
        *POSITION,
        Setting.new(:uint16, "Speed/time"),
        Setting.new(:uint16, "Setting 2")
      ],
      "AREA" => [
        Setting.new(:byte, "Shape"),
        Setting.new(:byte, "Type"),
        Setting.new(:byte, "Camera ID"),
        Setting.new(:byte, "Priority"),
        *POSITION,
        *ROTATION,
        *SCALE,
        Setting.new(:uint16, "Setting 1"),
        Setting.new(:uint16, "Setting 2"),
        Setting.new(:byte, "Route ID"),
        Setting.new(:byte, "ENPT ID"),
        Setting.new(:uint16, "Padding")
      ],
      "CAME" => [
        Setting.new(:byte, "Type"),
        Setting.new(:byte, "Next Camera"),
        Setting.new(:byte, "Camshake"),
        Setting.new(:byte, "Route"),
        Setting.new(:uint16, "Pointspeed"),
        Setting.new(:uint16, "Zoomspeed"),
        Setting.new(:uint16, "Viewspeed"),
        Setting.new(:byte, "Start flag"),
        Setting.new(:byte, "Movie flag"),
        *POSITION,
        *ROTATION,
        Setting.new(:float, "Zoom start"),
        Setting.new(:float, "Zoom end"),
        *POSITION,
        *POSITION,
        Setting.new(:float, "Time")
      ],
      "JGPT" => [
        *POSITION,
        *ROTATION,
        Setting.new(:uint16, "ID"),
        Setting.new(:int16, "Range")
      ],
      "CNPT" => [
        *POSITION,
        *ROTATION,
        Setting.new(:uint16, "ID"),
        Setting.new(:int16, "Shoot effect")
      ],
      "MSPT" => [
        *POSITION,
        *ROTATION,
        Setting.new(:uint16, "ID"),
        Setting.new(:uint16, "Padding")
      ],
      "STGI" => [
        Setting.new(:byte, "Lap count"),
        Setting.new(:byte, "Pole position"),
        Setting.new(:byte, "Distance"),
        Setting.new(:byte, "Enable lens flare"),
        Setting.new(:byte, "Padding"),
        Setting.new(:uint32, "Flare color"),
        Setting.new(:byte,  "Padding"),
        Setting.new(:uint16, "Speed mod")
      ]
    }

    def initialize
      super
      Dir["#{DIR}/test/kmps/*.kmp"].each do |old_path|
        start_test
        new_path = old_path[0...-4] + "-new.kmp"
        Data.entities.each { |ent| ent.erase! }
        KMPImporter.import(old_path)
        KMPExporter.export(new_path)
        @old_parser = BinaryParser.new(old_path)
        @new_parser = BinaryParser.new(new_path)
        compare_header
        15.times { compare_section }
        puts "Done comparing #{old_path}"
        File.delete(new_path)
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
      old_data, new_data = get_data_comparison(datatype)
      match = (old_data == new_data)
      assert(match, msg + " mismatch: #{new_data} != #{old_data}")
      return old_data
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
