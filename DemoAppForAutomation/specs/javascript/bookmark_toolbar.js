#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"

test("Behave toolbar buttons correctly", function(target, app) {
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(0.5);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.0);
  assertTrue(target.frontMostApp().windows()[1].buttons()[0].isEnabled());
  assertTrue(target.frontMostApp().windows()[1].buttons()[1].isEnabled());
  assertFalse(target.frontMostApp().windows()[1].buttons()[2].isEnabled());
  assertFalse(target.frontMostApp().windows()[1].buttons()[3].isEnabled());
  assertTrue(target.frontMostApp().windows()[1].buttons()[4].isEnabled());
  assertTrue(target.frontMostApp().windows()[1].buttons()[5].isEnabled());
  target.frontMostApp().windows()[1].buttons()[0].tap();
  target.frontMostApp().windows()[1].buttons()[0].tap();
  target.frontMostApp().windows()[1].buttons()[1].tap();
  target.frontMostApp().windows()[1].buttons()[1].tap();
  target.frontMostApp().windows()[1].buttons()[2].tap();
  target.frontMostApp().windows()[1].buttons()[2].tap();
  target.frontMostApp().windows()[1].buttons()[3].tap();
  target.frontMostApp().windows()[1].buttons()[3].tap();
  target.frontMostApp().windows()[1].buttons()[4].tap();
  target.frontMostApp().windows()[1].buttons()[4].tap();
  assertEquals(target.frontMostApp().windows()[1].buttons()[5].name(), "Public");
  target.frontMostApp().windows()[1].buttons()[5].tap();
  assertEquals(target.frontMostApp().windows()[1].buttons()[5].name(), "Private");
  assertFalse(target.frontMostApp().windows()[1].buttons()[0].isEnabled());
  assertFalse(target.frontMostApp().windows()[1].buttons()[1].isEnabled());
  assertFalse(target.frontMostApp().windows()[1].buttons()[2].isEnabled());
  assertFalse(target.frontMostApp().windows()[1].buttons()[3].isEnabled());
  assertTrue(target.frontMostApp().windows()[1].buttons()[4].isEnabled());
  target.frontMostApp().windows()[1].buttons()[0].tap();
  target.frontMostApp().windows()[1].buttons()[0].tap();
  target.frontMostApp().windows()[1].buttons()[5].tap();
  target.frontMostApp().windows()[1].buttons()[5].tap();
  target.frontMostApp().windows()[1].buttons()[4].tap();
  assertScreenMatchesImageNamed("bookmark_toolbar0", "bookmark toolbar view is not matched.", 0.03)
});
