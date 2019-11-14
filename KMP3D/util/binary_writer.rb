module KMP3D
  class BinaryWriter
    attr_accessor :bytes, :head

    def initialize(path)
      @path = path
      @bytes = ""
    end

    def write
      File.open(path, "wb") { |f| f.write(@bytes) }
    end

    def write_byte(data, pos = -1)
      @bytes.insert(pos, [data].pack("C").reverse)
    end

    def write_uint16(data, pos = -1)
      @bytes.insert(pos, [data].pack("S").reverse)
    end

    def write_int16(data, pos = -1)
      @bytes.insert(pos, [data].pack("s").reverse)
    end

    def write_uint32(data, pos = -1)
      @bytes.insert(pos, [data].pack("L").reverse)
    end

    def write_float(data, pos = -1)
      @bytes.insert(pos, [data].pack("F").reverse)
    end
  end
end
