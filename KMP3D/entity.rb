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
    transform = transformation
    array = transformation.to_a
    px =  transform.origin.x.to_m
    py = -transform.origin.y.to_m
    pz =  transform.origin.z.to_m
    return [px, pz, py] if model_type == "point" && !type?("GOBJ")
    sx = array[0...3].distance([0,0,0])
    sy = array[4...7].distance([0,0,0])
    sz = array[9...12].distance([0,0,0])
    if transform.zaxis.x == 1.0
      ry = 90
      rx = Math.atan2(-transform.xaxis.y, -transform.xaxis.z).radians
    elsif transform.zaxis.x == -1.0
      ry = -90
      rx = Math.atan2(transform.xaxis.y, transform.xaxis.z).radians
    else
      ry = Math.asin(transform.zaxis.x).radians.round
      rx = Math.atan2((transform.zaxis.y)/Math.cos(ry), \
                      (transform.zaxis.z)/Math.cos(ry)).radians.round
      rz = -Math.atan2((transform.yaxis.x)/Math.cos(ry), \
                       (transform.xaxis.x)/Math.cos(ry)).radians.round
    end
    return [px, pz, py, rx, rz, ry] if model_type == "vector"
    return checkpoint_transform(px, py, rz, sy) if model_type == "checkpoint"
    return [px, pz, py, rx, rz, ry, sx, sz, sy]
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
