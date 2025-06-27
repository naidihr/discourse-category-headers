import icon from "discourse/helpers/d-icon";
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class CategoryHeader extends Component {
  @service siteSettings;
  
  get ifParentCategory() {
    if (this.args.category.parentCategory) {
      return true;
    }
  }

  get catDesc() {
    if (settings.show_category_description) {
      return true;
    }
  }

  get logoImg() {
    if (settings.show_category_logo && this.args.category.uploaded_logo) {
      return this.args.category.uploaded_logo.url;
    } else if (settings.show_category_logo && settings.show_parent_category_logo && this.args.category.parentCategory && this.args.category.parentCategory.uploaded_logo) {
      return this.args.category.parentCategory.uploaded_logo.url;
    } else if (settings.show_site_logo && this.siteSettings.logo_small) {
      return this.siteSettings.logo_small;
    }
  }

  get ifParentProtected() {
    if (this.args.category.parentCategory && this.args.category.parentCategory.read_restricted) {
      return true;
    }
  }

  get ifProtected() {
    if (this.args.category.read_restricted) {
        return true;
    }
  }

  get lockIcon() {
    return settings.category_lock_icon || 'lock';
  }

  get showHeader() {
    console.log(this.args.category);
    const isException = this.args.category && settings.hide_category_exceptions.split("|").includes(this.args.category.name);
    const hideMobile = !settings.show_mobile && this.site.mobileView;
    const subCat = !settings.show_subcategory_header && this.args.category.parentCategory;
    const noDesc = !settings.hide_if_no_category_description && !this.args.category.description_text;
    const path = window.location.pathname;
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
      return <template>
        <div class="category-about-url">
          <a href="{{this.args.category.topic_url}}">{{settings.read_more_link_text}}</a>
        </div>
      </template>;
    }
  }
}
