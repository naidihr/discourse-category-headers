import { apiInitializer } from "discourse/lib/api";
import { h }  from "virtual-dom";
import { hbs } from "ember-cli-htmlbars";
import RenderGlimmer from "discourse/widgets/render-glimmer";
import icon from "discourse/helpers/d-icon";
import MountWidget from "discourse/components/mount-widget";
import { iconNode } from "discourse/lib/icon-library";

export default apiInitializer((api) => {
  api.createWidget('category-header-widget', {
      
  });

  api.decorateWidget('category-header-widget:after', helper => {
      helper.widget.appEvents.on('page:changed', () => {
          helper.widget.scheduleRerender();
      });
  });

  api.renderInOutlet("above-main-container",
    <template>
      <MountWidget
      @widget="category-header-widget"
      />
    </template>
  );
});

  
