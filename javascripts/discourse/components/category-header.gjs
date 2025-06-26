import { apiInitializer } from "discourse/lib/api";
import icon from "discourse/helpers/d-icon";
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class CategoryHeader extends Component {
  @service siteSettings;
  
  get ifParentCategory() {
    if (this.args.category.parentCategory) {
      return <template>
        <a class="parent-box-link" href="{{this.args.category.parentCategory.url}}">
          <h1>{{this.args.category.parentCategory.name}}: </h1>
        </a>
      </template>;
    }
  }

  get catDesc() {
    if (settings.show_category_description) {
      return <template><div class="cooked">{{this.args.category.description}}</div></template>;
    }
  }

  get logoImg() {
    if (settings.show_category_logo && this.args.category.uploaded_logo) {
      <template><img src=""></template>;
      return <template>
        <img src="{{this.args.category.uploaded_logo.url}}">
      </template>;
    } else if (settings.show_category_logo && settings.show_parent_category_logo && this.args.category.parentCategory && this.args.category.parentCategory.uploaded_logo) {
      return <template>
        <img src="{{this.args.category.parentCategory.uploaded_logo.url}}">
      </template>;
    } else if (settings.show_site_logo && siteSettings.logo_small) {
      return <template>
        <img src="{{siteSettings.logo_small}}">
      </template>;
    }
  }

  get  ifParentProtected() {
    if (this.args.category.parentCategory && this.args.category.parentCategory.read_restricted) {
      return true;
    }
  }

  get ifProtected() {
    if (this.args.category.read_restricted) {
        return true;
    }
  }

  get showHeader() {
    const isException = this.args.category && settings.hide_category_exceptions.split("|").includes(this.args.category.name);
    const hideMobile = !settings.show_mobile && this.site.mobileView;
    const subCat = !settings.show_subcategory_header && this.args.category.parentCategory;
    const noDesc = !settings.hide_if_no_category_description && !this.args.category.description_text;
    return (/^\/c\//.test(path)
      && !isException
      && !noDesc
      && !subCat
      && !hideMobile
    );
  }

  get getHeaderStyle() {
    let headerStyle = "";
    if (settings.header_style == "box") {
      headerStyle += "border-left: 6px solid #" + this.args.category.color + ";"
    }
    if (settings.header_style == "banner") {
      headerStyle += "background-color: #" + this.args.category.color + "; color: #" + this.args.category.text_color + ";"
    }
    if (this.args.category.uploaded_background) {
      if (settings.header_background_image != "outside"){
        headerStyle += "background-image: url(" + this.args.category.uploaded_background.url + ");" 
      }
    }
    return headerStyle;
  }
          
  get aboutTopicUrl() {
    if (settings.show_read_more_link && this.args.category.topic_url) {
      return h('div.category-about-url', [
        h('a', { "attributes": { "href": this.args.category.topic_url } }, settings.read_more_link_text)
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
                  <h1>{{this.args.category.name}}</h1>
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
