module KMP3D
  module WKMPTExporter
    module_function

    def export
      output = Data.types.map do |type|
        "[#{type.type_name}]\n" + \
        if type.type_name == "POTI" then export_route(type)
        elsif type.type_name == "STGI" then export_stage_info
        else type.external_settings ? export_group(type) : export_points(type)
        end
      end
      puts output
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
        g_id = settings.shift.to_i
        groups[g_id] ||= \
          ["$GROUP G#{g_id}, next: G#{type.table[g_id + 1] * ' '}"]
        groups[g_id] << settings_for(type.type_name, id, ent, settings)
        id += 1
      end
      return groups.map { |group| group * "\n" } * "\n\n"
    end

    def export_route(type)
      id = 0
      routes = []
      Data.kmp3d_entities(type.type_name).each do |ent|
        settings = ent.kmp3d_settings(type.type_name)
        r_id = settings.shift.to_i
        routes[r_id] ||= \
          ["$ROUTE r#{r_id}, settings: G#{type.table[r_id + 1] * ' '}"]
        routes[r_id] << settings_for(type.type_name, id, ent, settings)
        id += 1
      end
      return routes.map { |route| route * "\n" } * "\n\n"
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
      " #{id} #{ent.transformation.origin.to_a * ' '} #{settings * ' '}"
    end

    def vector_settings(id, ent, settings)
      " #{id} #{convert_transform(ent.transformation).first(6) * ' '}" \
      " #{settings * ' '}"
    end

    def checkpoint_settings(id, ent, settings)
      transform = convert_transform(ent.transformation)
      x, y  = transform[0], transform[2] # y is used because 2d
      angle = (transform[4] + 180).degrees
      scale = 1500 * transform[8]
      x1 = x + scale * Math.cos(angle)
      y1 = y + scale * Math.sin(angle)
      x2 = x - scale * Math.cos(angle)
      y2 = y - scale * Math.sin(angle)
      " #{id} #{x1} #{y1} #{x2} #{y2} #{settings * ' '} #{id - 1} #{id + 1}"
    end

    def convert_transform(trsfm)
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
