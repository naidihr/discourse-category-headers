import { apiInitializer } from "discourse/lib/api";
// import CategoryHeader from "../components/category-header";
import { tracked } from "@glimmer/tracking";
import icon from "discourse/helpers/d-icon";
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default apiInitializer((api) => {
  @tracked service = api.container.lookup("service:discovery");
  @tracked category = service.get("category");
  @service siteSettings;
  api.renderInOutlet(
    "above-main-container", 
    class CategoryHeader extends Component {
      get ifParentCategory() {
        if (this.category.parentCategory) {
          return true;
        }
      }
    
      get catDesc() {
        if (settings.show_category_description) {
          return true;
        }
      }
    
      get logoImg() {
        if (settings.show_category_logo && this.category.uploaded_logo) {
          return this.category.uploaded_logo.url;
        } else if (settings.show_category_logo && settings.show_parent_category_logo && this.category.parentCategory && this.category.parentCategory.uploaded_logo) {
          return this.category.parentCategory.uploaded_logo.url;
        } else if (settings.show_site_logo && this.siteSettings.logo_small) {
          return this.siteSettings.logo_small;
        }
      }
    
      get ifParentProtected() {
        if (this.category.parentCategory && this.category.parentCategory.read_restricted) {
          return true;
        }
      }
    
      get ifProtected() {
        if (this.category.read_restricted) {
            return true;
        }
      }
    
      get lockIcon() {
        return settings.category_lock_icon || 'lock';
      }
    
      get showHeader() {
        console.log(this.category);
        const isException = this.category && settings.hide_category_exceptions.split("|").includes(this.category.name);
        const hideMobile = !settings.show_mobile && this.site.mobileView;
        const subCat = !settings.show_subcategory_header && this.category.parentCategory;
        const noDesc = !settings.hide_if_no_category_description && !this.category.description_text;
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
          headerStyle += "border-left: 6px solid #" + this.category.color + ";"
        }
        if (settings.header_style == "banner") {
          headerStyle += "background-color: #" + this.category.color + "; color: #" + this.category.text_color + ";"
        }
        if (this.category.uploaded_background) {
          if (settings.header_background_image != "outside"){
            headerStyle += "background-image: url(" + this.category.uploaded_background.url + ");" 
          }
        }
        return headerStyle;
      }
              
      get aboutTopicUrl() {
        if (settings.show_read_more_link && this.category.topic_url) {
          return settings.read_more_link_text;
        }
      }
    
      <template>
        <h1>Hi</h1>
      </template>
    }
  );
});
