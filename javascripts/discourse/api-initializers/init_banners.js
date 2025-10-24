import { tracked } from "@glimmer/tracking";

import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.onPageChange((url) => {
    console.log(url.split("/c/")[1].split("/")[1].split("?")[0]);
  });
  api.renderInOutlet("above-category-heading", CategoryHeader);
});
