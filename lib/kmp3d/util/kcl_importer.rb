module KMP3D
  module KCLImporter
    module_function

    Color = Struct.new(:name, :color)

    FLAGS = [
      Color.new("Road", "Gray"),
      Color.new("Slippery Road", "LightSteelBlue"),
      Color.new("Weak Off-Road", "Wheat"),
      Color.new("Off-Road", "Tan"),
      Color.new("Heavy Off-Road", "Sienna"),
      Color.new("Slippery Road", "LightSteelBlue"),
      Color.new("Boost Pad", "Red"),
      Color.new("Boost Ramp", "Crimson"),
      Color.new("Jump Pad", "Yellow"),
      Color.new("Item Road", "Gold"),
      Color.new("Solid Fall", "DarkOrange"),
      Color.new("Moving Water", "Turquoise"),
      Color.new("Wall", "DarkSlateGray"),
      Color.new("Invisible Wall", "LightSlateGray"),
      Color.new("Item Wall", "DarkGoldenrod"),
      Color.new("Wall", "DarkSlateGray"),
      Color.new("Fall Boundary", "OrangeRed"),
      Color.new("Cannon Activator", "MediumPurple"),
      Color.new("Force Recalculation", "MediumOrchid"),
      Color.new("Half-pipe Ramp", "SteelBlue"),
      Color.new("Wall", "DarkSlateGray"),
      Color.new("Moving Road", "SlateBlue"),
      Color.new("Gravity Road", "LimeGreen"),
      Color.new("Road", "Gray"),
      Color.new("Sound Trigger", "MediumTurquoise"),
      Color.new("Unknown", "White"),
      Color.new("Effect Trigger", "MediumVioletRed"),
      Color.new("Unknown", "White"),
      Color.new("Unknown", "White"),
      Color.new("Moving Road", "SlateBlue"),
      Color.new("Special Wall", "DarkSlateBlue"),
      Color.new("Wall", "DarkSlateGray")
    ].freeze

    def import(path=nil)
      path ||= UI.openpanel(
        "Select a file to import from.", Data.model_dir, "KCL|*.kcl||"
      )
      return if path.nil?

      @parser = BinaryParser.new(path)

      sect1_offset = @parser.read_uint32
      sect2_offset = @parser.read_uint32
      sect3_offset = @parser.read_uint32
      sect4_offset = @parser.read_uint32

      @vertices  = read_vector_array(sect1_offset, sect2_offset)
      @normals   = read_vector_array(sect2_offset, sect3_offset)
      @triangles = parse_triangles(sect3_offset, sect4_offset)

      add_faces
      # Put the camera in a more favorable position when done
      Data.model.active_view.zoom_extents
    end

    def add_faces
      Data.model.start_operation("Import KCL")
      @triangles.each do |flag, triangles|
        mesh = Geom::PolygonMesh.new(0, triangles.length)
        triangles.each { |t| mesh.add_polygon(t) }
        group = Data.model.entities.add_group
        color = FLAGS[flag & 0x1f]
        material = Data.model.materials.add(color.name)
        material.color = color.color
        group.entities.fill_from_mesh(mesh, true, 0, material)
      end
      Data.model.commit_operation
    end

    def read_vector_array(offset1, offset2)
      @parser.head = offset1
      vectors = []
      vectors << @parser.read_vector3d while @parser.head < offset2
      return vectors
    end

    def parse_triangles(offset1, offset2)
      triangles = {}
      @parser.head = offset1 + 0x10
      while @parser.head < offset2
        length = @parser.read_float
        pos_index = @parser.read_uint16
        dir_index = @parser.read_uint16
        nrm_index_a = @parser.read_uint16
        nrm_index_b = @parser.read_uint16
        nrm_index_c = @parser.read_uint16
        basic_flag = @parser.read_uint16

        next if pos_index >= @vertices.length
        next if dir_index >= @normals.length
        next if nrm_index_a >= @normals.length
        next if nrm_index_b >= @normals.length
        next if nrm_index_c >= @normals.length

        vertex = @vertices[pos_index]
        direction = @normals[dir_index]

        normal_a = @normals[nrm_index_a]
        normal_b = @normals[nrm_index_b]
        normal_c = @normals[nrm_index_c]

        cross_a = normal_a.cross(direction)
        cross_b = normal_b.cross(direction)
        scale1 = length / cross_b.dot(normal_c)
        scale2 = length / cross_a.dot(normal_c)

        cross_b.transform!(Geom::Transformation.new(scale1))
        cross_a.transform!(Geom::Transformation.new(scale2))

        v1 = vertex.offset(cross_b).map { |vert| vert.m }
        v2 = vertex.offset(cross_a).map { |vert| vert.m }
        v3 = vertex.map { |vert| vert.m }

        next unless v1.all? { |v| v.finite? }
        next unless v2.all? { |v| v.finite? }
        next unless v3.all? { |v| v.finite? }

        triangles[basic_flag] ||= []
        triangles[basic_flag] << [v1, v2, v3]
      end
      return triangles
    end
  end
end
