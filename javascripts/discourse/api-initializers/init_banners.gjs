import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  let full_description = "";
  api.onPageChange(async function(url) {
    try {
      let cd = await ajax(`${url.split("/c/")[1].split("/")[1].split("?")[0]}.json`);
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
          @category={{this.args.category}}
        />
      </template>
    }
  );
});
