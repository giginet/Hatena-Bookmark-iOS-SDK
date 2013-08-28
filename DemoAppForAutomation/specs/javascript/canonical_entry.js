#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"

test("Can show bookmark view of canonicaled entry correctly", function(target, app) {
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()[1].tap();
  target.delay(0.5);
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(0.5);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.0);
  assertScreenMatchesImageNamed("canonical_entry", "bookmark view of canonicaled entry is not shown correctly.", 0.03)
  target.frontMostApp().mainWindow().scrollViews()[1].buttons()[1].tap();
  target.delay(1.0);
  assertScreenMatchesImageNamed("canonical_entry", "bookmark view of canonicaled entry is not shown correctly.", 0.03)
});
