import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", <template><h1>Hi</h1></template>);
});
