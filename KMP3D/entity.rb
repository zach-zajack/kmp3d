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
    KMP3D::Data.kmp3d_entities(type_name).index(self)
  end

  def kmp3d_group
    kmp3d_settings[0].to_i
  end

  def kmp_transform
    array = transformation.to_a
    pos = []
    pos.x =  transformation.origin.x.to_m
    pos.y =  transformation.origin.z.to_m
    pos.z = -transformation.origin.y.to_m
    return pos if model_type == "point" && !type?("GOBJ")
    rot = matrix_to_euler(array)
    return pos + rot if model_type == "vector"
    size = []
    size.x = array[0...3].distance([0,0,0])
    size.y = array[8...11].distance([0,0,0])
    size.z = array[4...7].distance([0,0,0])
    if model_type == "checkpoint"
      return checkpoint_transform(pos.x, pos.z, rot.y, size.z)
    end
    return pos + rot + size
  end

  def matrix_to_euler(array)
    # solution based off http://www.gregslabaugh.net/publications/euler.pdf
    if array[1].abs == 1.0
      sign = -array[1] <=> 0
      rot = []
      rot.y = -90*sign
      rot.x = Math.atan2(array[8]*sign, array[4]*sign).radians
      rot.z = 0
    else
      r1 = []
      r2 = []
      r1.y = Math.asin(array[1]).radians
      cos = Math.cos(r1.y.degrees)
      r1.x = Math.atan2(-array[9]/cos, array[5]/cos).radians
      r1.z = Math.atan2(array[2]/cos, array[0]/cos).radians
      r2.y = 180 - r1.y
      r2.x = Math.atan2(array[9]/cos, -array[5]/cos).radians
      r2.z = Math.atan2(-array[2]/cos, -array[0]/cos).radians
      if r1.select { |v| v.abs < 1e-6 }.length >= \
         r2.select { |v| v.abs < 1e-6 }.length then rot = r1
      else rot = r2
      end
    end
    return rot
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
