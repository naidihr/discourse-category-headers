import { apiInitializer } from "discourse/lib/api";
import CategoryHeader from "../components/category-header";

export default apiInitializer((api) => {
  api.renderInOutlet("above-category-heading", CategoryHeader);

  if (settings.show_category_follow_button) {
    api.onPageChange(() => {
      const onCategory = /^\/c\//.test(window.location.pathname);
      document.body.classList.toggle("ch-bell-relocated", onCategory);
    });
  }
});
