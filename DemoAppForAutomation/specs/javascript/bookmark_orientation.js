#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"
test("Show oriented bookmark view correctly", function(target, app) {
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(0.5);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.0);
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation0", "bookmark view on landscape left is not matched.", 0.03)
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT_UPSIDEDOWN);
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation0", "bookmark view on portrait upsidedown is not matched.", 0.03)
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
  target.delay(1.0);
});

test("Show oriented comment list view correctly", function(target, app) {
  target.frontMostApp().mainWindow().scrollViews()[1].buttons()[0].tap();
  target.delay(1.0);
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT);
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation1", "comment view on landscape right is not matched.", 0.03)
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT_UPSIDEDOWN);
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation1", "comment view on portrait upsidedown is not matched.", 0.03)
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation1", "comment view on landscape left is not matched.", 0.03)
  target.frontMostApp().navigationBar().leftButton().tap();
  target.delay(1.0);
  assertScreenMatchesImageNamed("bookmark_orientation0", "bookmark view on landscape left is not matched.", 0.03)
  target.frontMostApp().navigationBar().leftButton().tap();
  target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
});
