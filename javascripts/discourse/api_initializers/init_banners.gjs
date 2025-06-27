import { apiInitializer } from "discourse/lib/api";
import icon from "discourse/helpers/d-icon";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.renderInOutlet("above-category-heading",
  <template>
    <CategoryHeader @category={{this.args.outletArgs.category}} />
  </template>
  );
});
