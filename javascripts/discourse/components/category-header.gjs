import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";

import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";

export default class CategoryHeader extends Component {
  @service siteSettings;
  @service site;

  @tracked full_category_description;

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
      return this.args.category.uploaded_logo.url;
    } else if (
      settings.show_category_logo &&
      settings.show_parent_category_logo &&
      this.args.category.parentCategory &&
      this.args.category.parentCategory.uploaded_logo
    ) {
      return this.args.category.parentCategory.uploaded_logo.url;
    } else if (settings.show_site_logo && this.siteSettings.logo_small) {
      return this.siteSettings.logo_small;
    }
  }

  get ifParentProtected() {
    console.log(this.args.category);
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
      return settings.read_more_link_text;
    }
  }

  get inlineReadMore() {
    return (settings.inline_read_more && (settings.show_category_description || settings.show_full_category_description) && settings.show_read_more_link);
  }

  <template>
    {{#if this.showHeader}}
      <div
        class="category-title-header category-banner-{{@category.slug}}"
        style={{this.getHeaderStyle}}
      >
        <div class="category-title-contents">
          <div class="category-logo aspect-image">
            <img src={{this.logoImg}} />
          </div>
          <div class="category-title-name">
            {{#if this.ifParentProtected}}
              {{icon this.lockIcon}}
            {{/if}}
            {{#if this.ifParentCategory}}
              <a class="parent-box-link" href={{@category.parentCategory.url}}>
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
                    <a href={{@category.topic_url}}>{{this.aboutTopicUrl}}</a>
                  </span>
                {{/if}}
              </div>
            {{/if}}

            {{#if this.showFullCatDesc}}
              <div class="cooked">
                {{htmlSafe this.full_category_description}}
                {{#if this.inlineReadMore}}
                  <span class="category-about-url">
                    <a href={{@category.topic_url}}>{{this.aboutTopicUrl}}</a>
                  </span>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </div>

        {{#unless this.inlineReadMore}}
          <div class="category-about-url">
            <a href={{@category.topic_url}}>{{this.aboutTopicUrl}}</a>
          </div>
        {{/unless}}
      </div>
    {{/if}}
  </template>
}
