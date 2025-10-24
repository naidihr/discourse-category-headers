import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

import { apiInitializer } from "discourse/lib/api";
import { ajax } from "discourse/lib/ajax";

import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.renderInOutlet("above-category-heading", CategoryHeader);
});
