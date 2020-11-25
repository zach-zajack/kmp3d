module KMP3D
  module Observer
    def activate
      Data.reload(self)
      Data.load_kmp3d_model
      Sketchup.active_model.rendering_options["DrawHidden"] = false
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

    def onMouseMove(_flags, x, y, view)
      @comp.visible = false
      return if !@dlg.visible? || @type.on_external_settings?

      @ip.pick(view, x, y)
      unless @type.hide_point?
        @comp = @type.transform(@prev_comp.copy, @ip.position)
        @comp.layer = @type.name
        @comp.definition = @type.model
      end
      view.tooltip = @ip.tooltip if @ip.valid?
      Sketchup.status_text = @type.helper_text
      view.invalidate
    end

    def onLButtonDown(_flags, _x, _y, _view)
      return if !@ip.valid? || @type.on_external_settings?

      if @type.advance_steps(@ip.position) == 0
        @comp = @type.add_comp(@comp)
        Data.model.commit_operation
        add_row(@comp) unless @type.hybrid?
        update_comp
      end
      @prev_comp = @comp
    end

    def draw(view)
      @ip.draw(view)
      Data.layers.each do |layer|
        next unless layer.visible?

        type = Data.type_by_name(layer.name)
        type.draw_connected_points(view, @ip.position, type == @type) if type
      end
    end

    def onSelectionBulkChange(_)
      return if !@type || @type.hybrid?

      update_selection
      Data.selection.each do |ent|
        @prev_selection << ent
        update_row(ent)
      end
    end

    def onSelectionCleared(_)
      return if !@type || @type.hybrid?
      update_selection
    end

    def onOpenModel(_)
      Data.signal_reload
      @dlg.close if @dlg.visible?
    end

    def onNewModel(_)
      Data.signal_reload
      @dlg.close if @dlg.visible?
    end

    def onPreSaveModel(_)
      Data.model.abort_operation
      Data.types.each { |type| type.save_settings }
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
