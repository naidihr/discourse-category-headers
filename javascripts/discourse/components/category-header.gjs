import { apiInitializer } from "discourse/lib/api";
import icon from "discourse/helpers/d-icon";
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class CategoryHeader extends Component {
  @service siteSettings;
  const iconName = settings.category_lock_icon || 'lock'; // Fallback to 'lock' if setting is not defined
  const lockIcon = <template>{{icon iconName}}</template>;
  const path = window.location.pathname;
  let category;

  const service = api.container.lookup('service:discovery');
  category = service.get("category");
  
  get ifParentCategory() {
    if (category.parentCategory) {
      return <template>
        <a class="parent-box-link" href="{{category.parentCategory.url}}">
          <h1>{{category.parentCategory.name}}: </h1>
        </a>
      </template>;
    }
  }

  get catDesc() {
    if (settings.show_category_description) {
      return <template><div class="cooked">{{category.description}}</div></template>;
    }
  }

  get logoImg() {
    if (settings.show_category_logo && category.uploaded_logo) {
      <template><img src=""></template>;
      return <template>
        <img src="{{category.uploaded_logo.url}}">
      </template>;
    } else if (settings.show_category_logo && settings.show_parent_category_logo && category.parentCategory && category.parentCategory.uploaded_logo) {
      return <template>
        <img src="{{category.parentCategory.uploaded_logo.url}}">
      </template>;
    } else if (settings.show_site_logo && siteSettings.logo_small) {
      return <template>
        <img src="{{siteSettings.logo_small}}">
      </template>;
    }
  }

  get  ifParentProtected() {
    if (category.parentCategory && category.parentCategory.read_restricted) {
      return lockIcon;
    }
  }

  get ifProtected() {
    if (category.read_restricted) {
        return lockIcon;
    }
  }

  get showHeader() {
    const isException = category && settings.hide_category_exceptions.split("|").includes(category.name);
    const hideMobile = !settings.show_mobile && this.site.mobileView;
    const subCat = !settings.show_subcategory_header && category.parentCategory;
    const noDesc = !settings.hide_if_no_category_description && !category.description_text;
    return (/^\/c\//.test(path)
      && !isException
      && !noDesc
      && !subCat
      && !hideMobile
    );
  }

  if (/^\/c\//.test(path)) {

      
      if(!isException && !noDesc && !subCat && !hideMobile) {
          document.body.classList.add("category-header");
          //list-controls
          
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
        
          <template>
            <div class="category-title-header category-banner-{{category.slug}} style={{getHeaderStyle()}}>
              <div class="category-title-contents">
                <div class="category-logo aspect-image">{{logoImg()}}</div>
                <div class="category-title-name">
                  {{ifParentProtected()}}
                  {{ifParentCategory()}}
                  {{ifProtected()}}
                  <h1>{{category.name}}</h1>
                </div>
                <div class="category-title-description">{{catDesc()}}</div>
              </div>
              {{aboutTopicUrl()}}
            </div>
          </template>          
      }
  } else {
      document.body.classList.remove("category-header");
  }
}
