import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";

import LightDarkImg from "discourse/components/light-dark-img";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";

import { and, not } from "truth-helpers";

export default class CategoryHeader extends Component {
  @service siteSettings;
  @service site;

  @tracked full_category_description;
  @tracked isCatDescExpanded = false;

  constructor() {
    super(...arguments);
    this.getFullCatDesc();
  }

  get ifParentCategory() {
    if (this.args.category.parentCategory) {
      return true;
    }
  }

  get showCatDesc() {
    if (settings.show_category_description) {
      return true;
    }
  }

  get catDesc() {
    return this.args.category.description;
  }

  async getFullCatDesc() {
    try {
      let cd = await ajax(`${this.args.category.topic_url}.json`);
      this.full_category_description = cd.post_stream.posts[0].cooked;
    } catch {}
  }

  get showFullCatDesc() {
    if (settings.show_full_category_description) {
      return true;
    }
  }

  get logoImg() {
    if (settings.show_category_logo && this.args.category.uploaded_logo) {
      return this.args.category.uploaded_logo;
    } else if (
      settings.show_category_logo &&
      settings.show_parent_category_logo &&
      this.args.category.parentCategory &&
      this.args.category.parentCategory.uploaded_logo
    ) {
      return this.args.category.parentCategory.uploaded_logo;
    } else if (settings.show_site_logo && this.siteSettings.logo_small) {
      let map = {};
      map['url'] = this.siteSettings.logo_small
      return map;
    } else {
      return false;
    }
  }

  get darkLogoImg() {
    if (settings.show_dark_mode_category_logo && this.args.category.uploaded_logo_dark) {
      return this.args.category.uploaded_logo_dark;
    } else if (
      settings.show_dark_mode_category_logo &&
      settings.show_dark_mode_parent_category_logo &&
      this.args.category.parentCategory &&
      this.args.category.parentCategory.uploaded_logo_dark
    ) {
      return this.args.category.parentCategory.uploaded_logo_dark;
    } else if (settings.show_site_logo && this.siteSettings.logo_small) {
      let map = {};
      map['url'] = this.siteSettings.logo_small
      return map;
    } else {
      return this.args.category.uploaded_logo; // If no dark mode logo is uploaded, use the normal logo
    } 
  }

  get ifParentProtected() {
    if (
      this.args.category.parentCategory &&
      (
        this.args.category.parentCategory.permission === null ||
        this.args.category.parentCategory.read_restricted
      )
    ) {
      return true;
    }
  }

  get ifProtected() {
    if (
      this.args.category.permission === null ||
      this.args.category.read_restricted
    ) {
      return true;
    }
  }

  get lockIcon() {
    return settings.category_lock_icon || "lock";
  }

  get showHeader() {
    const isException =
      this.args.category &&
      settings.hide_category_exceptions
        .split("|")
        .includes(String(this.args.category.id));
    const hideMobile = !settings.show_mobile && this.site.mobileView;
    const subCat =
      !settings.show_subcategory_header && this.args.category.parentCategory;
    const noDesc =
      !settings.hide_if_no_category_description &&
      !this.args.category.description_text;
    const path = window.location.pathname;
    return (
      /^\/c\//.test(path) && !isException && !noDesc && !subCat && !hideMobile
    );
  }

  get getHeaderStyle() {
    let headerStyle = "";
    if (settings.header_style === "box") {
      headerStyle +=
        "border-left: 6px solid #" + this.args.category.color + ";";
    }
    if (settings.header_style === "banner") {
      headerStyle +=
        "background-color: #" +
        this.args.category.color +
        "; color: #" +
        this.args.category.text_color +
        ";";
    }
    if (settings.show_parent_category_background_image) {
      if (this.args.category.parentCategory) {
        if (
          settings.header_background_image !== "outside" &&
          this.args.category.parentCategory.uploaded_background
        ) {
          headerStyle +=
            "background-image: url(" +
            this.args.category.parentCategory.uploaded_background.url +
            ");";
        }
      } else if (this.args.category.uploaded_background) {
        if (settings.header_background_image !== "outside") {
          headerStyle +=
            "background-image: url(" +
            this.args.category.uploaded_background.url +
            ");";
        }
      }
    } else {
      if (this.args.category.uploaded_background) {
        if (settings.header_background_image !== "outside") {
          headerStyle +=
            "background-image: url(" +
            this.args.category.uploaded_background.url +
            ");";
        }
      }
    }
    return headerStyle + " display: block; margin-bottom: 1em;";
  }

  get aboutTopicUrl() {
    if (settings.show_read_more_link && this.args.category.topic_url) {
      return (this.isCatDescExpanded) ? settings.read_less_link_text : settings.read_more_link_text;
    }
  }

  get inlineReadMore() {
    return (settings.inline_read_more && (settings.show_category_description || settings.show_full_category_description) && settings.show_read_more_link);
  }

  @action
  expandCategoryDescription() {
    if (settings.expand_and_collapse_category_description) {
      const categoryDescriptionElement = document.getElementsByClassName("category-title-description")[0].children[0];
      const readMoreLink = document.getElementsByClassName("category-about-url")[0].children[0];   
      const fullCategoryDescription = this.getFullCatDesc;
      if (this.isCatDescExpanded === true) {
        // Collapse it
        categoryDescriptionElement.innerHTML = this.args.category.description;
        readMoreLink.textContent = this.aboutTopicUrl;
      } else {
        // Expand it
        categoryDescriptionElement.innerHTML = fullCategoryDescription;
        readMoreLink.textContent = this.aboutTopicUrl;
      }
    }
  }

  <template>
    {{#if this.showHeader}}
      <div
        class="category-title-header category-banner-{{@category.slug}}"
        style={{this.getHeaderStyle}}
      >
        <div class="category-title-contents">
          {{#if (and this.logoImg this.darkLogoImg)}}
            <div class="category-logo aspect-image">
              <LightDarkImg
                @lightImg={{this.logoImg}}
                @darkImg={{this.darkLogoImg}}
              />
            </div>
          {{/if}}
          <div class="category-title-name" style={{if (not this.logoImg) "padding: 0 !important;"}}>
            {{#if this.ifParentCategory}}
              <a class="parent-box-link" href={{@category.parentCategory.url}}>
                {{#if this.ifParentProtected}}
                  {{icon this.lockIcon}}
                {{/if}}
                <h1>{{@category.parentCategory.name}}: </h1>
              </a>
            {{/if}}
            {{#if this.ifProtected}}
              {{icon this.lockIcon}}
            {{/if}}
            <h1>{{@category.name}}</h1>
          </div>

          <div class="category-title-description">
            {{#if this.showCatDesc}}
              <div class="cooked">
                {{htmlSafe this.catDesc}}
                {{#if this.inlineReadMore}}
                  <span class="category-about-url">
                    <a href={{@category.topic_url}} {{on 'click' this.expandCategoryDescription}}>{{this.aboutTopicUrl}}</a>
                  </span>
                {{/if}}
              </div>
            {{/if}}

            {{#if this.showFullCatDesc}}
              <div class="cooked">
                {{htmlSafe this.full_category_description}}
                {{#if this.inlineReadMore}}
                  <span class="category-about-url">
                    <a href={{@category.topic_url}} {{on 'click' this.expandCategoryDescription}}>{{this.aboutTopicUrl}}</a>
                  </span>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </div>

        {{#unless this.inlineReadMore}}
          <div class="category-about-url">
            <a href={{@category.topic_url}} {{on 'click' this.expandCategoryDescription}}>{{this.aboutTopicUrl}}</a>
          </div>
        {{/unless}}
      </div>
    {{/if}}
  </template>
}
