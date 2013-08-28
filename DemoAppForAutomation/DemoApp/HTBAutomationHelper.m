//
//  HTBAutomationHelper.m
//  DemoApp
//
//  Created by giginet on 8/29/13.
//  Copyright (c) 2013 Hatena Co., Ltd. All rights reserved.
//

#import "HTBAutomationHelper.h"
#import "HTBHatenaBookmarkManager.h"

#import "Nocilla.h"

@implementation HTBAutomationHelper

+ (instancetype)sharedHelper
{
    static id _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (BOOL)setupForAutomation
{
    [[HTBHatenaBookmarkManager sharedManager] setConsumerKey:@"dummyoAuthToken==" consumerSecret:@"dummyoAuthTokenSecret="];
    [[LSNocilla sharedInstance] start];
    [self logout];
    [self stubAllRequests];
    
    return YES;
}

- (void)stubAllRequests
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dummy_top" ofType:@".html"];
    NSData *dummyPage = [NSData dataWithContentsOfFile:path];
    NSURL *url = [[NSURL alloc] initWithString:@"http://b.hatena.ne.jp/touch"];
    stubRequest(@"GET", [url absoluteString]).
    andReturn(200).
    withHeaders(@{@"Content-Type" : @"text/html"}).
    withBody([[NSString alloc] initWithData:dummyPage encoding:NSUTF8StringEncoding]);
    
    stubRequest(@"POST", @"https://www.hatena.ne.jp/oauth/initiate").
    andReturn(200).
    withBody(@"oauth_token=dummyoAuthToken%3D%3D&oauth_token_secret=dummyoAuthTokenSecret%3D&oauth_callback_confirmed=true");
    stubRequest(@"POST", @"https://www.hatena.com/oauth/token").
    andReturn(200).
    withBody(@"oauth_token=dummyoAuthToken%3D%3D&oauth_token_secret=dummyoAuthTokenSecret%3D&url_name=cinnamon&display_name=%e3%81%97%e3%81%aa%e3%82%82%e3%82%93");
    
    // get my Entry
    NSDictionary *myJSON = @{@"name" : @"hatena",
                             @"plususer" : @1,
                             @"is_oauth_twitter" : @1,
                             @"is_oauth_evernote" : @0,
                             @"is_oauth_facebook" : @1,
                             @"is_oauth_mixi_check" : @0
                             };
    NSData *data = [NSJSONSerialization dataWithJSONObject:myJSON options:NSJSONWritingPrettyPrinted error:nil];
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/my.json").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // get my tags
    NSDictionary *tagJSON = @{@"tags" : @[
                                      @{@"tag" : @"hatena", @"count" : @100},
                                      @{@"tag" : @"twitter", @"count" : @30},
                                      @{@"tag" : @"facebook", @"count" : @999},
                                      @{@"tag" : @"instagram", @"count" : @50}
                                      ]};
    
    NSData *tagData = [NSJSONSerialization dataWithJSONObject:tagJSON options:NSJSONWritingPrettyPrinted error:nil];
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/my/tags.json").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:tagData encoding:NSUTF8StringEncoding]);
    
    // get Entry
    NSDictionary *json = @{
                           @"url" : [url absoluteString],
                           @"favicon_url" : @"http://cdn-ak.favicon.st-hatena.com/?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch%2F",
                           @"entry_url" : @"http://b.hatena.ne.jp/entry/b.hatena.ne.jp/touch",
                           @"title" : @"はてなブックマーク for iPhone",
                           @"count" : @(467),
                           @"recommend_tags" : @[@"PC", @"iPhone", @"Hatena"],
                           @"smartphone_app_entry_url" : @"http://b.hatena.ne.jp/bookmarklet.touch?mode=comment&iphone_app=1&url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch"
                           };
    NSData *myData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    //stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/entry.json?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch&with_tag_recommendations=1").
    stubRequest(@"GET", @"^http://api\.b\.hatena\.ne\.jp/1/entry\.json.+".regex).
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding]);
    
    // get favicon
    UIImage *favicon = [UIImage imageNamed:@"favicon.ico"];
    stubRequest(@"GET", @"http://cdn-ak.favicon.st-hatena.com/?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch%2F").
    withHeaders(@{ @"Accept": @"image/*" }).
    andReturn(200).
    withBody(UIImagePNGRepresentation(favicon));
    
    // oAuth page
    stubRequest(@"GET", @"https://www.hatena.ne.jp/oauth/authorize?oauth_token=dummyoAuthToken%3D%3D").andReturn(200);
    
    // for Comment view
    stubRequest(@"GET", @"http://b.hatena.ne.jp/bookmarklet.touch?mode=comment&iphone_app=1&url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"text"}).
    withBody(@"Comments");
    
    [self stubAddBookmarkTestEntry];
    [self stubCanonicalTestEntry];
    [self stubEditBookmarkTestEntry];
    
}

- (void)login:(void (^)(void))success
{
    id loginStartObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kHTBLoginStartNotification
                                                                              object:nil queue:[NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              NSURL *url = [[NSURL alloc] initWithString:@"http://www.hatena.ne.jp/?oauth_token=dummyoAuthToken%3D%3D&oauth_verifier=dummyoAuthVarifier"];
                                                                              NSNotification *notification = [NSNotification notificationWithName:kHTBLoginFinishNotification object:nil userInfo:@{ kHTBApplicationLaunchOptionsURLKey : url }];
                                                                              [[NSNotificationCenter defaultCenter] postNotification:notification];
                                                                          }];
    [[HTBHatenaBookmarkManager sharedManager] authorizeWithSuccess:success failure:nil];
}

- (void)stubCanonicalTestEntry
{
    stubRequest(@"GET", @"http://dummy.com/canonical").
    andReturn(200).
    withHeaders(@{@"Content-Type" : @"text/html"});
    NSDictionary *canonicalJSON = @{
                                    @"canonical_url" : @"http://dummy.com/canonical",
                                    @"original_url" : @"http://dummy.com/canonical",
                                    @"canonical_entry" : @{
                                            @"smartphone_app_entry_url" : @"http://b.hatena.ne.jp/bookmarklet.touch?mode=comment&iphone_app=1&url=http%3A%2F%2Fstaff.hatenablog.com%2F",
                                            @"title" : @"はてなブログ開発ブログ",
                                            @"entry_url" : @"http://b.hatena.ne.jp/entry/staff.hatenablog.com/",
                                            @"url" : @"http://staff.hatenablog.com/",
                                            @"favicon_url" : @"http://cdn-ak.favicon.st-hatena.com/?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch%2F",
                                            @"count" : @101
                                            }
                                    };
    NSData *canonicalData = [NSJSONSerialization dataWithJSONObject:canonicalJSON
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/canonical_entry.json?url=http%3A%2F%2Fdummy.com%2Fcanonical").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:canonicalData encoding:NSUTF8StringEncoding]);
    
    // get bookmarkedEntry
    NSData *bookmarkedData = [NSJSONSerialization dataWithJSONObject:@{}
                                                             options:NSJSONWritingPrettyPrinted error:nil];
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/my/bookmark.json?url=http%3A%2F%2Fdummy.com%2Fcanonical").
    andReturn(404);
    
}

- (void)stubAddBookmarkTestEntry
{
    stubRequest(@"GET", @"http://dummy.com/bookmarked").
    andReturn(200).
    withHeaders(@{@"Content-Type" : @"text/html"});
    NSData *canonicalData = [NSJSONSerialization dataWithJSONObject:@{}
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/canonical_entry.json?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:canonicalData encoding:NSUTF8StringEncoding]);
    
    NSData *bookmarkedData = [NSJSONSerialization dataWithJSONObject:@{}
                                                             options:NSJSONWritingPrettyPrinted error:nil];
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/my/bookmark.json?url=http%3A%2F%2Fb.hatena.ne.jp%2Ftouch").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:bookmarkedData encoding:NSUTF8StringEncoding]);
    
}

- (void)stubEditBookmarkTestEntry
{
    NSData *canonicalData = [NSJSONSerialization dataWithJSONObject:@{}
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/canonical_entry.json?url=http%3A%2F%2Fdummy.com%2Fbookmarked").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:canonicalData encoding:NSUTF8StringEncoding]);
    
    // get bookmarkedEntry
    NSDictionary *bookmarkedJSON = @{
                                     @"comment" : @"便利情報",
                                     @"tags" : @[@"これはひどい", @"あとで読む", @"増田"],
                                     @"created_epoch" : @1333234800,
                                     @"private" : @1
    };
    
    NSData *bookmarkedData = [NSJSONSerialization dataWithJSONObject:bookmarkedJSON
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:nil];
    stubRequest(@"GET", @"http://api.b.hatena.ne.jp/1/my/bookmark.json?url=http%3A%2F%2Fdummy.com%2Fbookmarked").
    andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).
    withBody([[NSString alloc] initWithData:bookmarkedData encoding:NSUTF8StringEncoding]);
}

- (void)logout
{
    [[HTBHatenaBookmarkManager sharedManager] logout];
}

- (void)dealloc
{
    [[LSNocilla sharedInstance] stop];
}

@end
