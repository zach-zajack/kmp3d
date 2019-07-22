module KMP3D
  module Observer
    def activate
      @dlg.show unless @dlg.visible?
      refresh_html
    end

    def deactivate(view)
      view.invalidate
    end

    def onMouseMove(flags, x, y, view)
      @ip.pick(view, x, y)
      view.tooltip = @ip.tooltip if @ip.valid?
      Sketchup.status_text = type.helper_text
      view.invalidate
    end

    def onLButtonDown(flags, x, y, view)
      @ip.pick(view, x, y)
      return unless @ip.valid? && !type.on_group_settings?
      ph = view.pick_helper
      ph.do_pick(x, y)
      ent = ph.best_picked
      if ent && ent.kmp3d_object?
        type.add_to_component(ent)
      else
        type.add_to_model(@ip.position)
      end
      refresh_html
    end

    def onSelectionBulkChange(_)
      refresh_html
    end

    def onSelectionCleared(_)
      refresh_html
    end

    def onOpenModel(_)
      Data.reload(self)
      refresh_html
    end

    def onPreSaveModel(_)
      Data.types.each { |type| type.save_settings }
    end

    def draw(view)
      @ip.draw(view)
    end
  end
end
