import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { and, not, or } from "truth-helpers";
import LightDarkImg from "discourse/components/light-dark-img";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import CategoryNotificationsWrapper from "./category-notifications-wrapper";

// Cache for full category descriptions (keyed by category ID)
const descriptionCache = new Map();

export default class CategoryHeader extends Component {
  @service siteSettings;
  @service site;
  @service router;

  @tracked full_cat_desc;
  @tracked isCatDescExpanded = false;
  @tracked isLoadingFullDesc = false;

  currentCategoryId = null;
  loadingCategoryId = null;

  constructor() {
    super(...arguments);
    this.syncCategoryDescriptionState();
    if (settings.show_full_category_description) {
      this.getFullCatDesc();
    }
    this._onPageChanged = this._onPageChanged.bind(this);
    this.router.on("routeDidChange", this._onPageChanged);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.router.off("routeDidChange", this._onPageChanged);
  }

  // eslint-disable-next-line no-unused-vars
  async _onPageChanged(transition) {
    this.syncCategoryDescriptionState({ collapse: true });

    // Only fetch if show_full_category_description is enabled
    if (settings.show_full_category_description) {
      await this.getFullCatDesc();
    }
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
    if (!this.args.category?.topic_url) {
      return;
    }

    const categoryId = this.args.category.id;

    // Check cache first
    if (descriptionCache.has(categoryId)) {
      this.full_cat_desc = descriptionCache.get(categoryId);
      return;
    }

    // Prevent duplicate requests for the same category
    if (this.isLoadingFullDesc && this.loadingCategoryId === categoryId) {
      return;
    }

    this.loadingCategoryId = categoryId;
    this.isLoadingFullDesc = true;

    try {
      const cd = await ajax(`${this.args.category.topic_url}.json`);
      const fullDesc = cd.post_stream.posts[0].cooked;

      // Cache the result
      descriptionCache.set(categoryId, fullDesc);
      if (this.currentCategoryId === categoryId) {
        this.full_cat_desc = fullDesc;
      }
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error("Failed to load full category description:", e);
    } finally {
      if (this.loadingCategoryId === categoryId) {
        this.isLoadingFullDesc = false;
        this.loadingCategoryId = null;
      }
    }
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
      map["url"] = this.siteSettings.logo_small;
      return map;
    } else {
      return false;
    }
  }

  get darkLogoImg() {
    if (
      settings.show_dark_mode_category_logo &&
      this.args.category.uploaded_logo_dark
    ) {
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
      map["url"] = this.siteSettings.logo_small;
      return map;
    } else {
      return this.args.category.uploaded_logo; // If no dark mode logo is uploaded, use the normal logo
    }
  }

  get ifParentProtected() {
    if (
      this.args.category.parentCategory &&
      (this.args.category.parentCategory.permission === null ||
        this.args.category.parentCategory.read_restricted)
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
    // Fixed: Correct logic for hiding when description is missing
    const hideNoDesc =
      settings.hide_if_no_category_description &&
      !this.args.category.description_text;
    const path = this.router.currentURL || window.location.pathname;
    return (
      /^\/c\//.test(path) &&
      !isException &&
      !hideNoDesc &&
      !subCat &&
      !hideMobile
    );
  }

  get getHeaderStyle() {
    const styles = [];

    // Set CSS custom properties for dynamic values
    if (this.args.category.color) {
      styles.push(`--category-color: #${this.args.category.color}`);
    }
    if (this.args.category.text_color) {
      styles.push(`--category-text-color: #${this.args.category.text_color}`);
    }

    // Background image handling
    let bgImageUrl = null;
    if (settings.header_background_image !== "outside") {
      if (settings.show_parent_category_background_image) {
        if (
          this.args.category.parentCategory?.uploaded_background?.url
        ) {
          bgImageUrl =
            this.args.category.parentCategory.uploaded_background.url;
        } else if (this.args.category.uploaded_background?.url) {
          bgImageUrl = this.args.category.uploaded_background.url;
        }
      } else if (this.args.category.uploaded_background?.url) {
        bgImageUrl = this.args.category.uploaded_background.url;
      }
    }

    if (bgImageUrl) {
      styles.push(`--category-bg-image: url(${bgImageUrl})`);
    }

    return styles.length > 0 ? htmlSafe(styles.join("; ")) : null;
  }

  get aboutTopicUrl() {
    if (settings.show_read_more_link && this.args.category.topic_url) {
      return this.isCatDescExpanded &&
        settings.expand_and_collapse_category_description
        ? settings.read_less_link_text
        : settings.read_more_link_text;
    }
  }

  get inlineReadMore() {
    return (
      settings.inline_read_more &&
      (settings.show_category_description ||
        settings.show_full_category_description) &&
      settings.show_read_more_link
    );
  }

  get showChevronToggle() {
    const ui = settings.category_description_toggle_ui;
    return ui === "chevron_only" || ui === "both";
  }

  get showReadMoreUI() {
    const ui = settings.category_description_toggle_ui;
    return ui === "read_more_only" || ui === "both";
  }

  get fullCatDescRemainder() {
    if (!this.full_cat_desc || !this.catDesc) {
      return null;
    }
    const full = this.full_cat_desc.trim();
    const excerpt = this.catDesc.trim();
    if (full.startsWith(excerpt)) {
      return full.slice(excerpt.length).trim();
    }
    return null;
  }

  @action
  async expandCategoryDescription(event) {
    if (settings.expand_and_collapse_category_description) {
      event?.preventDefault?.();
      this.syncCategoryDescriptionState();

      // If expanding and we don't have the full description yet, fetch it
      if (!this.isCatDescExpanded && !this.full_cat_desc) {
        await this.getFullCatDesc();
      }

      this.isCatDescExpanded = !this.isCatDescExpanded;
    }
  }

  syncCategoryDescriptionState({ collapse = false } = {}) {
    const categoryId = this.args.category?.id ?? null;
    const categoryChanged = this.currentCategoryId !== categoryId;

    if (categoryChanged) {
      this.currentCategoryId = categoryId;
      this.full_cat_desc = categoryId
        ? descriptionCache.get(categoryId) ?? null
        : null;
    } else if (
      categoryId &&
      !this.full_cat_desc &&
      descriptionCache.has(categoryId)
    ) {
      this.full_cat_desc = descriptionCache.get(categoryId);
    }

    if (collapse || categoryChanged) {
      this.isCatDescExpanded = false;
    }
  }

  @action
  handleToggleKeydown(event) {
    // Support Enter and Space for keyboard accessibility
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.expandCategoryDescription(event);
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

          <div class="category-title-text-wrapper">
            <div
              class="category-title-name"
              style={{unless this.logoImg "padding: 0 !important;"}}
            >
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

              {{#if settings.show_category_follow_button}}
                <span class="category-notifications-wrap">
                  <CategoryNotificationsWrapper @category={{@category}} />
                </span>
              {{/if}}

              {{#if (and
                settings.expand_and_collapse_category_description
                this.showCatDesc
                (not this.showFullCatDesc)
                this.showChevronToggle
              )}}
                <span class="category-desc-toggle">
                  <button
                    class="category-desc-toggle__btn"
                    type="button"
                    aria-expanded={{if this.isCatDescExpanded "true" "false"}}
                    aria-controls="category-description-{{@category.id}}"
                    {{on "click" this.expandCategoryDescription}}
                    {{on "keydown" this.handleToggleKeydown}}
                  >
                    {{icon (if this.isCatDescExpanded "chevron-up" "chevron-down")}}
                  </button>
                </span>
              {{/if}}
            </div>

            <div class="category-title-description">
              {{#if (or this.showCatDesc this.showFullCatDesc)}}
                <div
                  class="cooked"
                  id="category-description-{{@category.id}}"
                >
                  {{#if this.showFullCatDesc}}
                    {{htmlSafe this.full_cat_desc}}
                  {{else}}
                    <div class="category-description__excerpt">
                      {{htmlSafe this.catDesc}}
                    </div>
                    {{#if this.isCatDescExpanded}}
                      <div class="category-description__full">
                        {{htmlSafe (or this.fullCatDescRemainder this.full_cat_desc)}}
                      </div>
                    {{/if}}
                  {{/if}}

                  {{#if (and this.inlineReadMore this.showReadMoreUI)}}
                    <span class="category-about-url">
                      {{#if
                        (and
                          settings.expand_and_collapse_category_description
                          this.showCatDesc
                          (not this.showFullCatDesc)
                        )
                      }}
                        {{! template-lint-disable no-invalid-interactive}}
                        <a
                          href="#"
                          role="button"
                          aria-expanded={{if this.isCatDescExpanded "true" "false"}}
                          aria-controls="category-description-{{@category.id}}"
                          {{on "click" this.expandCategoryDescription}}
                          {{on "keydown" this.handleToggleKeydown}}
                        >{{this.aboutTopicUrl}}</a>
                      {{else}}
                        <a href={{@category.topic_url}}>{{this.aboutTopicUrl}}</a>
                      {{/if}}
                    </span>
                  {{/if}}
                </div>
              {{/if}}
            </div>

            {{#if (and (not this.inlineReadMore) this.showReadMoreUI)}}
              <div class="category-about-url">
                {{#if
                  (and
                    settings.expand_and_collapse_category_description
                    this.showCatDesc
                    (not this.showFullCatDesc)
                  )
                }}
                  {{! template-lint-disable no-invalid-interactive}}
                  <a
                    href="#"
                    role="button"
                    aria-expanded={{if this.isCatDescExpanded "true" "false"}}
                    aria-controls="category-description-{{@category.id}}"
                    {{on "click" this.expandCategoryDescription}}
                    {{on "keydown" this.handleToggleKeydown}}
                  >{{this.aboutTopicUrl}}</a>
                {{else}}
                  <a href={{@category.topic_url}}>{{this.aboutTopicUrl}}</a>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
