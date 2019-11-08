module KMP3D
  class Hybrid < Type
    attr_accessor :hybrid_types

    def initialize
      @name = "Hybrid"
      @point = Point.new
      @vector = Vector.new
      @hybrid_types = {}
      super
    end

    def model
      any_vectors? ? @vector.model : @point.model
    end

    def transform(comp, pos)
      any_vectors? ? @vector.transform(comp, pos) : @point.transform(comp, pos)
    end

    def advance_steps(pos)
      any_vectors? ? @vector.advance_steps(pos) : @point.advance_steps(pos)
    end

    def helper_text
      any_vectors? ? @vector.helper_text : @point.helper_text
    end

    def component_settings
      selected_types.map { |t| Data.type_by_name(t).component_settings } * ""
    end

    def on_external_settings?
      selected_types.length == 0
    end

    def to_html
      tag(:div, :class => "hybrid") do
        checkboxes * br + br + \
        "Group number if applicable: " + \
        tag(:input, :id => "hybridGroup", :type => "text", :size => "2", \
          :value => @group, :onchange => callback("setHybridGroup"))
      end
    end

    private

    def any_vectors?
      (selected_types & ["KTPT", "JGPT", "CNPT", "MSPT"]).length > 0
    end

    def selected_types
      @hybrid_types.map { |id, selected| id if selected }.compact
    end

    def checkboxes
      Data.hybrid_types.map do |type|
        value = @hybrid_types[type.type_name]
        checkbox(type.name, {:id => "hybrid#{type.type_name}", :value => value,
          :onclick => callback("setHybridType", type.type_name)}, value)
      end
    end
  end
end
