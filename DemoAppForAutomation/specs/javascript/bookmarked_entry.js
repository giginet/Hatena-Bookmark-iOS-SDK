#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"

test("Can show bookmark view of bookmarked entry correctly", function(target, app) {
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()[2].tap();
  target.delay(0.5);
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(0.5);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.0);
  assertEquals(target.frontMostApp().mainWindow().scrollViews()[1].textViews()[0].value(), "便利情報");
  assertEquals(target.frontMostApp().mainWindow().scrollViews()[1].textFields()[0].value(), "これはひどい あとで読む 増田");
  assertEquals(target.frontMostApp().mainWindow().scrollViews()[1].staticTexts()[0].name(), "4");
  assertScreenMatchesImageNamed("bookmarked_entry", "bookmark view of bookmarked entry is not shown correctly.", 0.03)
});
