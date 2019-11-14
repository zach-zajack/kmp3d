module KMP3D
  class BinaryParser
    attr_accessor :bytes, :head

    def initialize(path)
      @bytes = File.open(path, "rb").read
      @head = 0
    end

    def read(num)
      b = @bytes[@head, num]
      @head += num
      return b
    end

    def next_bytes(num)
      return read(num).reverse
    end

    def read_byte
      next_bytes(1).unpack("C").first
    end

    def read_uint16
      next_bytes(2).unpack("S").first
    end

    def read_int16
      next_bytes(2).unpack("s").first
    end

    def read_uint32
      next_bytes(4).unpack("L").first
    end

    def read_float
      next_bytes(4).unpack("F").first
    end

    def read_vector3d
      x = read_float.m
      z = read_float.m
      y = -read_float.m
      [x, y, z]
    end

    def read_rotation
      x = read_float.degrees
      z = read_float.degrees
      y = -read_float.degrees
      [x, y, z]
    end

    def read_vector2d
      x = read_float.m
      y = -read_float.m
      [x, y]
    end
  end
end
