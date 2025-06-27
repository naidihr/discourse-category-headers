import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";
import { tracked } from "@glimmer/tracking";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", CategoryHeader);
});
