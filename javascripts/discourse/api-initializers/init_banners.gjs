import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  let full_description = "";
  api.onPageChange((url) => {
    console.log(url.split("/c/")[1].split("/")[1].split("?")[0]);
    try {
      let cd = await ajax(`${this.args.category.topic_url}.json`);
      full_description = cd.post_stream.posts[0].cooked;
    } catch (e) {
      // eslink-disable-next-line no-console
      console.error(e);
    }
  });
  api.renderInOutlet(
    "above-category-heading",
    class CategoryHeaderInit extends Component {
      <template>
        <CategoryHeader
          @full_category_description={{full_description}}
        />
      </template>
    }
  );
});
