#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"
test("Show bookmark view correctly", function(target, app) {
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(1.0);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.5);
  assertScreenMatchesImageNamed("can_show_bookmark_view", "Bookmark view is not matched.", 0.035)
});

test("Show tag keyboard on bookmark view correctly", function(target, app) {
  target.delay(0.5);
  target.frontMostApp().mainWindow().scrollViews()[1].textFields()[0].tap();
  target.frontMostApp().windows()[1].toolbar().segmentedControls()[0].buttons()["Recommended"].tap();
  assertScreenMatchesImageNamed("check_tag_keyboard0", "Recommanded keyboard is not matched.", 0.03)

  target.frontMostApp().windows()[1].toolbar().segmentedControls()[0].buttons()["Tags"].tap();
  assertScreenMatchesImageNamed("check_tag_keyboard1", "My tag keyboard is not matched.", 0.03)

  target.frontMostApp().windows()[1].scrollViews()[0].buttons()["hatena"].tap();
  target.delay(0.2);
  target.frontMostApp().windows()[1].scrollViews()[0].buttons()["instagram"].tap();
  target.delay(0.2);
  target.frontMostApp().windows()[1].scrollViews()[0].buttons()["twitter"].tap();
  target.delay(0.2);
  assertScreenMatchesImageNamed("check_tag_keyboard2", "Pressed my tag keyboard is not matched.", 0.03)
  assertEquals(target.frontMostApp().mainWindow().scrollViews()[1].textFields()[0].value(), "hatena instagram twitter");

});

test("Show comment list view correctly", function(target, app) {
  target.frontMostApp().mainWindow().scrollViews()[1].buttons()[0].tap();
  target.delay(0.5);
  assertScreenMatchesImageNamed("can_show_comment_view", "Comment list view is not shown correctly.", 0.05)
  assertEquals(target.frontMostApp().mainWindow().scrollViews()[1].webViews()[0].staticTexts()[0].label(), "Comments");
  target.frontMostApp().navigationBar().leftButton().tap();
});
