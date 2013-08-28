#import "../../tuneup_js/tuneup.js"
#import "lib/setup_image_asserter.js"

test("Show logout sheet correctly", function(target, app) {
  target.frontMostApp().toolbar().buttons()["Login"].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(1.0);
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  target.delay(1.0);
  assertEquals(target.frontMostApp().navigationBar().buttons()[0].label(), "id:cinnamon");
  target.frontMostApp().navigationBar().buttons()["id:cinnamon"].tap();
  target.delay(0.5);
  assertEquals(target.frontMostApp().actionSheet().buttons()[0].label(), "Logout");
  assertEquals(target.frontMostApp().actionSheet().buttons()[1].label(), "Cancel");
  assertEquals(target.frontMostApp().actionSheet().staticTexts()[0].label(), "Logout");
  assertScreenMatchesImageNamed("can_show_logout_sheet", "Logout sheet is not shown correctly.", 0.03)
});

test("Can cancel to log out", function(target, app) {
  target.frontMostApp().actionSheet().cancelButton().tap();
  target.delay(1.0);
  assertNull(target.frontMostApp().actionSheet());
});

test("Can log out via logout button.", function(target, app) {
  // show logout actionsheet
  target.frontMostApp().navigationBar().buttons()["id:cinnamon"].tap();
  target.delay(1.0);
  target.frontMostApp().actionSheet().buttons()["Logout"].tap();
  target.delay(1.0);
  // top view. modal bookmark activity.
  target.frontMostApp().navigationBar().rightButton().tap();
  target.delay(1.0);
  // if it is successed to log out, show 'Authorization Required' alert.
  target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"].tap();
  UIATarget.onAlert = function(alert) {
      assertEquals(alert.name(), 'Authorization Required');
      return true;
  };
  target.delay(1);
});
