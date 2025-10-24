import { tracked } from "@glimmer/tracking";

import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.onPageChange((url) => {
    console.log(url);
  });
  api.renderInOutlet("above-category-heading", CategoryHeader);
});
