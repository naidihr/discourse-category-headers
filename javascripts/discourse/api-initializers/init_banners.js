import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

import { apiInitializer } from "discourse/lib/api";
import { ajax } from "discourse/lib/ajax";

import CategoryHeader from "../components/category-header";

// export default apiInitializer((api) => {
//   let full_description = "";
//   api.onPageChange(async function(url) {
//     try {
//       const category = await ajax(`/c/${url.split("/c/")[1].split("/")[1].split("?")[0]}.json`);
//       if (category) {
//         const about_topic_id = category.topic_list.topics[0].id;
//         const about_topic = ajax(`/t/${about_topic_id}.json`);
//         console.log
//       }
//     } catch (e) {
//       // eslink-disable-next-line no-console
//       console.error(e);
//     }
//   });
//   api.renderInOutlet(
//     "above-category-heading",
//     class CategoryHeaderInit extends Component {
//       <template>
//         <CategoryHeader
//           @full_category_description={{full_description}}
//           @category={{this.args.category}}
//         />
//       </template>
//     }
//   );
// });

export default apiInitializer((api) => {
  api.renderInOutlet("above-category-heading", CategoryHeader);
});
