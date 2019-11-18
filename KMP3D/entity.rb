class Sketchup::Entity
  def kmp3d_object?
    false
  end

  def model_type
    nil
  end

  def type?(type_name)
    false
  end

  def kmp3d_settings
    nil
  end

  def kmp3d_settings_insert(index, value)
  end

  def kmp3d_id(type_name)
    nil
  end
end

class Sketchup::ComponentInstance
  def kmp3d_object?
    name[0, 5] == "KMP3D"
  end

  def model_type
    definition.path[definition.path.rindex(/[\\\/]/)+1...-4]
  end

  def type?(type_name)
    name.include?(type_name)
  end

  def kmp3d_settings
    name[name.index("(") + 1..name.index(")") - 1].split(",")
  end

  def kmp3d_settings_insert(index, value)
    settings = kmp3d_settings
    settings[index + 1] = value # spot 1 is for the group number
    name_clone = name
    name_clone[name.index("(") + 1..name.index(")") - 1] = settings.join(",")
    self.name = name_clone
  end

  def kmp3d_id(type_name)
    KMP3D::Data.kmp3d_entities(type_name).index(self).to_s
  end

  def kmp3d_group
    kmp3d_settings[0].to_i
  end

  def kmp_transform
    array = transformation.to_a
    px =  transformation.origin.x.to_m
    py =  transformation.origin.z.to_m
    pz = -transformation.origin.y.to_m
    return [px, py, pz] if model_type == "point" && !type?("GOBJ")
    # solution from https://www.learnopencv.com/rotation-matrix-to-euler-angles/
    sy = Math.sqrt(array[0]**2 + array[2]**2)
    ry = Math.atan2(array[1], sy).radians
    if sy > 1e-6
      rx = Math.atan2(-array[9], array[5]).radians
      rz = Math.atan2(array[2], array[0]).radians
    else
      rx = Math.atan2(array[6], array[10]).radians
      rz = 0
    end
    return [px, py, pz, rx, ry, rz] if model_type == "vector"
    sx = array[0...3].distance([0,0,0])
    sy = array[8...11].distance([0,0,0])
    sz = array[4...7].distance([0,0,0])
    return checkpoint_transform(px, pz, ry, sz) if model_type == "checkpoint"
    return [px, py, pz, rx, ry, rz, sx, sy, sz]
  end

  def checkpoint_transform(x, y, angle, scale)
    angle = (90 - angle).degrees
    scale *= 1500
    x1 = x - scale * Math.cos(angle)
    y1 = y - scale * Math.sin(angle)
    x2 = x + scale * Math.cos(angle)
    y2 = y + scale * Math.sin(angle)
    return [x1, y1, x2, y2]
  end
end
