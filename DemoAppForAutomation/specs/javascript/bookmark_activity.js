// Generated by CoffeeScript 1.6.3
#import "../../tuneup_js/tuneup.js"
(function() {
  test("Show Hatena Bookmark Activity", function(target, app) {
    var window;
    target.delay(2);
    window = app.mainWindow();
    window.navigationBars()[0].rightButton().tap();
    return assertTrue(target.frontMostApp().activityView().scrollViews()[0].buttons()["Hatena Bookmark"] != null);
  });

}).call(this);