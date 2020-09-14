module KMP3D
  class BinaryWriter
    attr_accessor :bytes

    def initialize(path)
      @path = path
      @bytes = ""
    end

    def write_to_file
      File.open(@path, "wb") { |f| f.write(@bytes) }
    end

    def head
      @bytes.length
    end

    def write(data)
      @bytes += data
    end

    def write_byte(data)
      @bytes += [hexify(data)].pack("C")
    end

    def write_uint16(data)
      @bytes += [hexify(data)].pack("S").reverse
    end

    def write_int16(data)
      @bytes += [hexify(data)].pack("s").reverse
    end

    def write_uint32(data)
      @bytes += [hexify(data)].pack("L").reverse
    end

    def write_float(data)
      @bytes += [data.to_f].pack("F").reverse
    end

    def write_vector3d(data)
      p data
      write_float(data.x)
      write_float(data.z)
      write_float(-data.y)
    end

    def insert_uint32(pos, data)
      @bytes[pos, 4] = [hexify(data)].pack("L").reverse
    end

    private

    def hexify(data)
      data.to_s[0,2] == "0x" ? data.hex : data.to_i
    end
  end
end
