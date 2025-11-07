# Changelog - Category Headers Theme Component

## v2.3.0 - UX Improvement: Persistent Excerpt on Expansion

### Fixed Category Description Expansion Behavior
**Problem**: When users clicked the chevron icon or "Read more" link to expand the full category description, the excerpt (preview text) disappeared completely, making it harder to understand the context.

**Solution**:
- Modified the template to always render the excerpt when in toggle mode
- Full description now appears below the excerpt when expanded, rather than replacing it
- Matches Discourse's standard "Read More" pattern where preview text persists
- Added smart de-duplication: if the full description starts with the excerpt text, only the remainder is shown to avoid redundancy
- Added BEM-style classes (`.category-description__excerpt` and `.category-description__full`) for better styling control

**User Experience**:
- Excerpt remains visible throughout expand/collapse interaction
- Full content appears below with appropriate spacing when expanded
- Collapsing removes only the full content, keeping the excerpt visible
- Works with all toggle UI modes: chevron icon, "Read more" link, or both

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: Added `fullCatDescRemainder` getter and updated template (lines 247-259, 319-366)
- `common/common.scss`: Added styling for excerpt and full description blocks (lines 145-155)

---

## v2.0.0 - Comprehensive Improvements

### Overview
This release includes comprehensive improvements addressing critical bugs, accessibility issues, performance optimizations, and modernization of the codebase following Discourse best practices.

---

## Critical Fixes

### 1. Fixed Image/Description Overlap Issue
**Problem**: Category images were overlapping with description text due to float-based layout applying to both container and image elements.

**Solution**:
- Replaced float-based layout with modern flexbox
- Applied size constraints only to `<img>` element (not container)
- Added `object-fit: contain` and `max-width: 100%` for proper image scaling
- Improved responsive behavior across all logo positions (left, right, top)

**Files Changed**:
- `common/common.scss`: Lines 31-155
- Removed double-floating issue
- Added flex-based positioning with proper order control

### 2. Fixed Mobile Selector Targeting
**Problem**: Mobile styles were targeting non-existent `.category-header` and `.category-header-widget` containers.

**Solution**:
- Updated selectors to target actual component classes (`.category-title-header`)
- Properly implemented mobile-first responsive design
- Added flexbox column layout for mobile when `force_mobile_alignment` is enabled

**Files Changed**:
- `mobile/mobile.scss`: Complete rewrite (lines 1-19)

---

## High Priority Fixes

### 3. Fixed Header Visibility Logic
**Problem**: The `hide_if_no_category_description` setting had inverted logic, causing headers to show when they should be hidden.

**Solution**:
- Corrected boolean logic in `showHeader()` getter
- Renamed variable from `noDesc` to `hideNoDesc` for clarity
- Now properly hides header when setting is enabled AND description is missing

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: Lines 142-163

### 4. Added Accessibility Features to Toggle Link
**Problem**: The expand/collapse toggle lacked proper ARIA attributes and keyboard support.

**Solution**:
- Added `role="button"` for semantic correctness
- Added `aria-expanded` attribute (dynamically updates based on state)
- Added `aria-controls` linking to description container
- Implemented keyboard support (Enter and Space keys)
- Added `handleToggleKeydown` action for keyboard events
- Added unique `id` to description container for ARIA reference

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: 
  - Lines 258-277 (actions)
  - Lines 279-342 (template updates)

---

## Medium Priority Optimizations

### 5. Implemented Lazy Loading with Caching
**Problem**: Full category description was fetched on every page load and route change, even when not needed.

**Solution**:
- Created module-level cache (`Map`) keyed by category ID
- Only fetch full description when:
  - `show_full_category_description` setting is enabled, OR
  - User clicks to expand description for the first time
- Added loading state tracking to prevent duplicate requests
- Cache persists across route changes within the same session

**Performance Impact**:
- Eliminates unnecessary network requests
- Reduces initial page load time
- Improves navigation performance

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: Lines 1-99, 258-270

### 6. Refactored Inline Styles to CSS Variables
**Problem**: Large inline style strings made theming difficult and mixed concerns.

**Solution**:
- Moved dynamic styling to CSS custom properties:
  - `--category-color`: Category background color
  - `--category-text-color`: Category text color
  - `--category-bg-image`: Background image URL
- SCSS now uses these variables with fallbacks
- Reduced inline style string by ~80%
- Improved maintainability and theme customization

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: Lines 194-227
- `common/common.scss`: Lines 5-34

### 7. Improved Mobile Responsive Design
**Solution**:
- Consolidated mobile rules with proper flexbox
- Ensured proper responsive behavior across all breakpoints
- Fixed alignment issues on mobile devices
- Proper order reset for logo positioning on mobile

**Files Changed**:
- `mobile/mobile.scss`: Complete rewrite

---

## Low Priority Improvements

### 8. Replaced Hard-coded Colors with Theme Variables
**Problem**: Border color used hard-coded `rgb(232.9, 232.9, 232.9)` value.

**Solution**:
- Replaced with Discourse CSS variable `var(--primary-low)`
- Ensures proper theming in light/dark modes
- Follows Discourse design system

**Files Changed**:
- `common/common.scss`: Line 14

### 9. Use Router Service for Route Checks
**Problem**: Using `window.location.pathname` is not SPA-friendly.

**Solution**:
- Updated to use `this.router.currentURL` with fallback
- More reliable in Discourse's SPA architecture
- Prevents mismatches during route transitions

**Files Changed**:
- `javascripts/discourse/components/category-header.gjs`: Line 156

### 10. Updated Metadata
**Solution**:
- Added `minimum_discourse_version: "3.2.0"`
- Added `theme_version: "2.0.0"`
- Added `authors` field
- Improves compatibility tracking and version management

**Files Changed**:
- `about.json`: Lines 6-8

---

## Technical Details

### Architecture Improvements
1. **Layout System**: Float-based → Flexbox
2. **State Management**: Added proper caching with `Map`
3. **Styling Strategy**: Inline styles → CSS custom properties
4. **Accessibility**: Added WCAG 2.1 compliant keyboard/ARIA support
5. **Performance**: Lazy loading with request deduplication

### Browser Compatibility
- All changes use modern CSS/JS features supported in Discourse 3.2+
- Flexbox has universal support
- CSS custom properties supported in all modern browsers
- No breaking changes for existing installations

### Testing Recommendations
Test the following scenarios:
1. **Logo Positions**: left, right, top
2. **Logo Sizes**: small, standard, original
3. **Header Styles**: box, banner, none
4. **Background Images**: contain, cover, resize, outside
5. **Mobile**: With and without `force_mobile_alignment`
6. **Accessibility**: 
   - Screen reader navigation
   - Keyboard-only navigation (Tab, Enter, Space)
   - ARIA attribute verification
7. **Performance**: 
   - Network tab (verify lazy loading)
   - Multiple category navigations (verify caching)
8. **Edge Cases**:
   - Categories without descriptions
   - Categories without logos
   - Parent/subcategory combinations
   - Light/dark mode switching

---

## Migration Notes

### Breaking Changes
None. All changes are backward compatible.

### Settings
No new settings added. All existing settings continue to work as expected (with bug fixes).

### Customizations
If you have custom CSS targeting:
- `.category-header` or `.category-header-widget`: Update to `.category-title-header`
- Float-based overrides: May need adjustment for flexbox layout

---

## Credits
- Original component by naidihr
- Improvements based on Discourse modern best practices (2025)
- Follows Discourse Theme Component guidelines

