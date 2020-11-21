module KMP3D
  module KMP
    Setting = Struct.new(:datatype, :msg)

    POSITION = [
      Setting.new(:float, "Position X"),
      Setting.new(:float, "Position Y"),
      Setting.new(:float, "Position Z")
    ].freeze

    ROTATION = [
      Setting.new(:float, "Rotation X"),
      Setting.new(:float, "Rotation Y"),
      Setting.new(:float, "Rotation Z")
    ].freeze

    SCALE = [
      Setting.new(:float, "Scale X"),
      Setting.new(:float, "Scale Y"),
      Setting.new(:float, "Scale Z")
    ].freeze

    GROUP = [
      Setting.new(:byte, "Group start"),
      Setting.new(:byte, "Group length"),
      *Array.new(6) { |i| Setting.new(:byte, "Prev group #{i}") },
      *Array.new(6) { |i| Setting.new(:byte, "Next group #{i}") },
      Setting.new(:uint16, "Padding")
    ].freeze

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
        *Array.new(2) { |i| Setting.new(:uint16, "Setting #{i + 1}") }
      ],
      "ENPH" => GROUP,
      "ITPT" => [
        *POSITION,
        Setting.new(:float, "Size"),
        *Array.new(2) { |i| Setting.new(:uint16, "Setting #{i + 1}") }
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
        *Array.new(8) { |i| Setting.new(:uint16, "Setting #{i + 1}") },
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
        *Array.new(2) { |i| Setting.new(:uint16, "Setting #{i + 1}") },
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
        Setting.new(:byte, "Padding"),
        Setting.new(:uint16, "Speed mod")
      ]
    }.freeze
  end
end
