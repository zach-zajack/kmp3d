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
      @bytes += [data.to_i].pack("C")
    end

    def write_uint16(data)
      @bytes += [data.to_i].pack("S").reverse
    end

    def write_int16(data)
      @bytes += [data.to_i].pack("s").reverse
    end

    def write_uint32(data)
      @bytes += [data.to_i].pack("L").reverse
    end

    def write_float(data)
      @bytes += [data.to_f].pack("F").reverse
    end

    def insert_uint32(pos, data)
      @bytes[pos, 4] = [data.to_i].pack("L").reverse
    end
  end
end
