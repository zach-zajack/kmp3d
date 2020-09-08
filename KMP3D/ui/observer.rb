module KMP3D
  module Observer
    def activate
      Data.load_kmp3d_model
      @dlg.show unless @dlg.visible?
      @id = Data.model.tools.active_tool_id
      refresh_html
      update_comp
      @prev_focus = nil
    end

    def tool_active?
      @id == Data.model.tools.active_tool_id
    end

    def update_comp
      Data.model.start_operation("Add KMP3D Point")
      @type.step = 0
      @comp = Data.entities.add_instance(@type.model, IDENTITY)
      @comp.visible = false
      @prev_comp = @comp
      @undone = false
    end

    def deactivate(view)
      @comp.erase! # ensure comp gets removed
      Data.model.abort_operation
      view.invalidate
      refresh_html
    end

    def onMouseMove(flags, x, y, view)
      @comp.visible = false
      return if !@dlg.visible? || @type.on_external_settings?
      @ip.pick(view, x, y)
      @comp = @type.transform(@prev_comp.copy, @ip.position)
      @comp.layer = @type.name
      @comp.definition = @type.model
      view.tooltip = @ip.tooltip if @ip.valid?
      Sketchup.status_text = @type.helper_text
      view.invalidate
    end

    def onLButtonDown(flags, x, y, view)
      return if !@ip.valid? || @type.on_external_settings?
      if @type.advance_steps(@ip.position) == 0
        @type.add_comp(@comp)
        Data.model.commit_operation
        add_row(@comp) unless @type.hybrid?
        update_comp
      end
      @prev_comp = @comp
    end

    def draw(view)
      @ip.draw(view)
      view.draw(GL_TRIANGLES, @comp)
      if @type.camera?
        view.draw(GL_LINE, [@ip.position]) if @type.step == 1
      elsif !@type.object?
        view.drawing_color = (@type.vector? ? "Aqua" : "Crimson")
        view.line_stipple = "-"
        view.line_width = 5
        array = @type.points_array + [@ip.position]
        view.draw_polyline(array) if array.length >= 2
      end
    end

    def onSelectionBulkChange(_)
      return if @type.hybrid?
      update_selection
      Data.selection.each do |ent|
        @prev_selection << ent
        update_row(ent)
      end
    end

    def onSelectionCleared(_)
      return if @type.hybrid?
      update_selection
    end

    def onOpenModel(_)
      Data.reload(self)
      @dlg.close if @dlg.visible?
    end

    def onNewModel(_)
      Data.reload(self)
      @dlg.close if @dlg.visible?
    end

    def onPreSaveModel(_)
      Data.model.abort_operation
      Data.types.each { |type| @type.save_settings }
    end

    def onTransactionUndo(_) # replace with onCancel at some point
      return if !tool_active? || @undone
      @undone = true # prevent recursion
      Sketchup.undo # call a second undo since new operation has already started
      update_comp
      refresh_html
    end

    def onTransactionRedo(_)
      return unless tool_active?
      refresh_html
    end

    private

    def update_selection
      @prev_selection.each { |ent| update_row(ent) }
      @prev_selection = []
    end
  end
end
