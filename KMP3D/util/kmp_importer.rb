module KMP3D
  module KMPImporter
    def import
      path = UI.openpanel("Select a file to import from.")
      @parser = BinaryParser.new(path)
      read_header
    end

    def read_header
      error("invalid file type") unless @parser.read(4) == "RKMD"
      @parser.read_uint32
      sections = @parser.read_uint16
      header_length = @parser.read_uint16
      section_offsets = Array.new(sections) { @parser.read_uint32 }
      error("invalid header length") unless @parser.head == header_length
      
    end

    def error(message)

    end
  end
end
