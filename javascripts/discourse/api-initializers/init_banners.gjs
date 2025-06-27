import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.renderInOutlet("above-category-heading", <template><CategoryHeader @category={{@outletArgs.category}}</template>);
});
