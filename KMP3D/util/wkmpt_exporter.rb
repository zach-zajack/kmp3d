module KMP3D
  module WKMPTExporter
    module_function

    def export
      path = UI.savepanel("Select a file to export to.")
      output = file_head + Data.types.map do |type|
        "[#{type.type_name}]\n" + \
        case type.type_name
        when "POTI" then export_route(type)
        when "GOBJ" then export_object(type)
        when "STGI" then export_stage_info
        else type.external_settings ? export_group(type) : export_points(type)
        end
      end
      File.open(path, "w") { |f| f.write(output * "\n") }
    end

    def file_head
      [ "#KMP",
        "#####################################################################",
        "# This is a textual representation of a KMP file used in Nintendo's #",
        '# "Mario Kart Wii". "Wiimms SZS Tools" can convert binary (raw) and #',
        "# text KMP files in both directions. The text parser supports       #",
        "# variables, C like expressions and nested IF-THEN-ELSE and LOOP    #",
        "# structures.                                                       #",
        "#                                                                   #",
        "# Info about the general parser syntax and semantics:               #",
        "#   * https://szs.wiimm.de/doc/syntax                               #",
        "#                                                                   #",
        "# Info about the KMP text syntax and semantics:                     #",
        "#   * https://szs.wiimm.de/doc/kmp/syntax                           #",
        "#                                                                   #",
        "# Reference list of KMP parser functions:                           #",
        "#   * https://szs.wiimm.de/doc/kmp/func                             #",
        "#                                                                   #",
        "# Info about the KMP file format:                                   #",
        "#   * https://szs.wiimm.de/r/wiki/KMP                               #",
        "#####################################################################",
        "# Exported via KMP3D, a SketchUp plugin that is used as a 3D        #",
        "# interface for Nintendo KMP files.                                 #",
        "#                                                                   #",
        "# Download and tutorial for KMP3D:                                  #",
        "#   * http://wiki.tockdom.com/wiki/KMP3D                            #",
        "#####################################################################"
      ]
    end

    def export_points(type)
      id = 0
      points = []
      Data.kmp3d_entities(type.type_name).each do |ent|
        settings = ent.kmp3d_settings(type.type_name)[1..-1]
        points << settings_for(type.type_name, id, ent, settings)
        id += 1
      end
      return points * "\n"
    end

    def export_group(type)
      id = 0
      groups = []
      Data.kmp3d_entities(type.type_name).each do |ent|
        settings = ent.kmp3d_settings(type.type_name)
        index = settings.shift.to_i
        next_groups = type.table[index + 1][0].delete(" ").split(",").join(" G")
        groups[index] ||= ["$GROUP G#{index}, next: G#{next_groups}"]
        groups[index] << settings_for(type.type_name, id, ent, settings)
        id += 1
      end
      return groups.map { |group| group * "\n" } * "\n\n"
    end

    def export_route(type)
      id = 0
      routes = []
      Data.kmp3d_entities(type.type_name).each do |ent|
        settings = ent.kmp3d_settings(type.type_name)
        index = settings.shift.to_i
        routes[index] ||= \
          ["$ROUTE r#{index}, settings: G#{type.table[index + 1] * ' '}"]
        routes[index] << settings_for(type.type_name, id, ent, settings)
        id += 1
      end
      return routes.map { |route| route * "\n" } * "\n\n"
    end

    def export_object(type)
      id = 0
      objects = []
      Data.kmp3d_entities(type.type_name).each do |ent|
        settings = ent.kmp3d_settings(type.type_name)
        index = settings.shift.to_i
        transform = convert_4x4_matrix(ent.transformation)
        position  = transform[0..2]
        rotation  = transform[3..5]
        scale     = transform[6..8]
        route     = settings[0]
        settings1 = settings[1..4]
        settings2 = settings[5..8]
        flag      = settings[9]
        objects << " o#{id} #{type.table[index + 1][0]}" \
                   " #{position * ' '} #{settings1 * ' '} #{route}" \
                   " 0 #{rotation * ' '} #{settings2 * ' '} #{flag}" \
                   " #{scale * ' '}"
        id += 1
      end
      return objects * "\n"
    end

    def export_stage_info
      " s0 " + Data.types.last.table.last * " "
    end

    def settings_for(type_name, id, ent, settings)
      case type_name
      when "CKPT" then checkpoint_settings(id, ent, settings)
      when "KTPT", "JGPT", "MSPT" then vector_settings(id, ent, settings)
      when "ENPT", "ITPT", "POTI" then point_settings(id, ent, settings)
      end
    end

    def point_settings(id, ent, settings)
      " #{id} #{convert_4x4_matrix(ent.transformation).first(3) * ' '}" \
      " #{settings * ' '}"
    end

    def vector_settings(id, ent, settings)
      " #{id} #{convert_4x4_matrix(ent.transformation).first(6) * ' '}" \
      " #{settings * ' '}"
    end

    def checkpoint_settings(id, ent, settings)
      transform = convert_4x4_matrix(ent.transformation)
      x, y  = transform[0], transform[2] # y is used because 2d
      angle = (transform[4] - 90).degrees
      scale = 1500 * transform[8]
      x1 = x + scale * Math.cos(angle)
      y1 = y + scale * Math.sin(angle)
      x2 = x - scale * Math.cos(angle)
      y2 = y - scale * Math.sin(angle)
      " #{id} #{x1} #{y1} #{x2} #{y2} #{settings * ' '} #{id - 1} #{id + 1}"
    end

    def convert_4x4_matrix(trsfm)
      px =  trsfm.origin.x.to_m
      py =  trsfm.origin.z.to_m # sketchup switches y for z
      pz = -trsfm.origin.y.to_m # also flips the y coordinate
      sx = Math.sqrt(trsfm.xaxis.x**2 + trsfm.xaxis.y**2 + trsfm.xaxis.z**2)
      sy = Math.sqrt(trsfm.yaxis.x**2 + trsfm.yaxis.y**2 + trsfm.yaxis.z**2)
      sz = Math.sqrt(trsfm.zaxis.x**2 + trsfm.zaxis.y**2 + trsfm.zaxis.z**2)
      if trsfm.zaxis.x/sz == 1.0
        ry = -90
        rx = Math.atan2(-trsfm.xaxis.y/sx, -trsfm.xaxis.z/sx).radians
      elsif trsfm.zaxis.x/sz == -1.0
        ry = 90
        rx = Math.atan2(trsfm.xaxis.y/sx, trsfm.xaxis.z/sx).radians
      else
        ry = -Math.asin(trsfm.zaxis.x/sz).radians
        rx = Math.atan2((trsfm.zaxis.y/sz)/Math.cos(ry), \
                        (trsfm.zaxis.z/sz)/Math.cos(ry)).radians
        rz = Math.atan2((trsfm.yaxis.x/sy)/Math.cos(ry), \
                        (trsfm.xaxis.x/sx)/Math.cos(ry)).radians
      end
      return [px, py, pz, rx, rz, ry, sx, sz, sy].map { |n| n.round }
    end
  end
end
