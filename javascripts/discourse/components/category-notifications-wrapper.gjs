import Component from "@glimmer/component";
import { action } from "@ember/object";
import CategoryNotificationsTracking from "discourse/components/category-notifications-tracking";

export default class CategoryNotificationsWrapper extends Component {
  @action
  onChange(level) {
    this.args.category.setNotification(level);
  }

  <template>
    <CategoryNotificationsTracking
      @levelId={{@category.notification_level}}
      @onChange={{this.onChange}}
      @showFullTitle={{false}}
      @showCaret={{false}}
      @triggerClass="category-header-notifications-trigger"
    />
  </template>
}
