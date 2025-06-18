import { apiInitializer } from "discourse/lib/api";
import { h }  from "virtual-dom";
import { iconNode } from "discourse-common/lib/icon-library";
import { tracked } from "@ember/tracking";
import MountWidget from "discourse/components/mount-widget";

export default apiInitializer((api) => {
  @tracked iconName = settings.category_lock_icon || 'lock'; // Fallback to 'lock' if setting is not defined
  @tracked lockIcon = iconNode(iconName);

  api.createWidget('category-header-widget', {
      tagName: 'span',
      html(attrs, state) {

          const path = window.location.pathname;
          let category;

          const service = api.container.lookup('service:discovery');
          category = service.get("category");
          const siteSettings = this.siteSettings;

          const isException = category && settings.hide_category_exceptions.split("|").includes(category.name);

          if(/^\/c\//.test(path)) {
              const hideMobile = !settings.show_mobile && this.site.mobileView;
              const subCat = !settings.show_subcategory_header && category.parentCategory;
              const noDesc = !settings.hide_if_no_category_description && !category.description_text;
              
              if(!isException && !noDesc && !subCat && !hideMobile) {
                  document.body.classList.add("category-header");
                  //list-controls
                  
                  function ifParentCategory(){
                    if (category.parentCategory) {
                        return h('a.parent-box-link',{"attributes" : {"href" : category.parentCategory.url}}, h('h1',category.parentCategory.name + ": "));
                    }
                  }

                  function catDesc() {
                      if(settings.show_category_description) {
                          return h('div.cooked', {innerHTML: category.description});
                      }
                  }
                  
                  function logoImg() {
                     if(settings.show_category_logo && category.uploaded_logo){
                        return [h('img',{"attributes" : {"src" : category.uploaded_logo.url}})];
                     } else if (settings.show_category_logo && settings.show_parent_category_logo && category.parentCategory && category.parentCategory.uploaded_logo) {
                        return [h('img',{"attributes" : {"src" : category.parentCategory.uploaded_logo.url}})];                        
                     } else if (settings.show_site_logo && siteSettings.logo_small) {
                        return [h('img',{"attributes" : {"src" : siteSettings.logo_small}})];
                     }
                  }
                  
                  function ifParentProtected() {
                      if(category.parentCategory && category.parentCategory.read_restricted) {
                          return lockIcon;
                      }
                  }                  

                  function ifProtected() {
                      if(category.read_restricted) {
                          return lockIcon;
                      }
                  }
                  
                  function getHeaderStyle() {
                      let headerStyle = "";
                      if(settings.header_style == "box"){
                        headerStyle += "border-left: 6px solid #" + category.color + ";"
                      }
                      if(settings.header_style == "banner"){
                        headerStyle += "background-color: #" + category.color + "; color: #" + category.text_color + ";"
                      }
                      if(category.uploaded_background){
                          if(settings.header_background_image != "outside"){
                                headerStyle += "background-image: url(" + category.uploaded_background.url + ");" 
                         }
                      }
                      return headerStyle;
                  }
                  
                  function aboutTopicUrl() {
                    if (settings.show_read_more_link && category.topic_url) {
                      return h('div.category-about-url', [
                        h('a', { "attributes": { "href": category.topic_url } }, settings.read_more_link_text)
                      ]);
                    }
                  }
                  
                  return h('div.category-title-header' + " .category-banner-" + category.slug, {
                      "attributes" : {
                          "style" : getHeaderStyle()
                      }
                  }, [
                    h('div.category-title-contents', [ 
                      h('div.category-logo.aspect-image', logoImg()), 
                      h('div.category-title-name', [
                        ifParentProtected(),                      
                        ifParentCategory(),                      
                        ifProtected(),
                        h('h1', category.name)
                      ]),
                      h('div.category-title-description', catDesc())
                    ]),
                    aboutTopicUrl()
                  ]);
              }
          } else {
              document.body.classList.remove("category-header");
          }
      }
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

  
