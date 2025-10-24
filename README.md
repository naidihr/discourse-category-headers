# Discourse Category Header theme component

This theme component provides a number of enhancements and custom settings for the discourse category header.

The default core Discourse category header is displayed on the category page above the navigation links. It is ONLY visible if a category logo image is uploaded in the category settings. The settings also allow for upload a category background image, which is displayed as a background image over the whole page.

## This theme component provides the following enhancements

### Theme settings

- <b>show category name:</b> Show the category name in the header
- <b>show category description:</b> Show the category description text (the first paragraph of the "About this category" topic)
- <b>description text size:</b> Size of text within the category description
- <b>text align: </b>Alignment of the text within the category header
- <b>show subcategory header:</b> Show header for subcategories
- <b>show parent category name:</b> Prefix the parent category name on the subcategory headers (this acts as a breadcrumb link to the parent category page)
- <b>show lock icon:</b> Show the lock icon on categories protected by permissions
- <b>show category logo:</b> Show the category logo image within the header
- <b>show parent category logo:</b> Show the parent category logo when a subcategory logo is not set
- <b>show site logo:</b> Show the small site logo if a category logo is not set
- <b>position logo:</b> Position of the logo within the header.
  <br>-- 'left' and 'right' display the logo inline with the text.
  <br>-- 'top' displays the logo above aligned with the text
- <b>size logo:</b> Position of the logo within the header.
  <br>-- Small is 50px high similar to a subcategory box logo.
  <br>-- Standard is 150px high.
  <br>-- Original is the size of the image uploaded
- <b>header style:</b> Set the header style to either:
  <br>-- Box: the category header is displayed in the same style as the standard Discourse boxes
  <br>-- Banner: set the header background to the category background color and text to the foreground color
  <br>-- None: no styling
- <b>header background image:</b> Applies if you have uploaded a category background image
  <br>-- 'contain', 'cover' and 'resize' display the background within the header.
  <br>-- 'outside' is the Discourse default displaying it outside the header, over the whole page.
- <b>show mobile: </b>Show category header on mobile devices
- <b>force mobile alignment:</b> Force mobile alignment of logo-text to the top-centre of the header
- <b>hide if no category description:</b> Hide header if category description is not set
- <b>hide category exceptions:</b> Headers will not show for these categories
- <b>show read more link:</b> Show a "Read more" link at the bottom of the category header
- <b>read more link text:</b> Customize the text for the "Read more" link

### New Features

- <b>Read More Link:</b> An optional "Read more" link can now be added to the bottom of the category header. This link directs users to the full "About this category" topic.
- <b>Customizable Link Text:</b> The text for the "Read more" link can be customized to suit your community's needs.

These new features provide more flexibility in guiding users to additional category information and can be easily toggled on or off through the theme settings.

For further information, please see the instructions and screenshots on Discourse Meta.
https://meta.discourse.org/t/discourse-category-headers-theme-component/148682
