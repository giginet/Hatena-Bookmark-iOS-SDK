//
//  HTBViewController.m
//  DemoApp
//
//  Copyright (c) 2013 Hatena Co., Ltd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "HTBDemoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HatenaBookmarkSDK.h"

#ifdef AUTOMATION
#import "HTBAutomationHelper.h"
#endif

@implementation HTBDemoViewController  {
    IBOutlet UIWebView *_webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTitleTextAttributes:@{
        UITextAttributeFont: [UIFont boldSystemFontOfSize:12.f],
    }];

    [self initializeHatenaBookmarkClient];
    [self toggleLoginButtons];
    
    [self loadHatenaBookmark];
}

-(void)loadHatenaBookmark {
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://b.hatena.ne.jp/touch"]];

    [_webView loadRequest:req];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [_webView.request.URL absoluteString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)topButtonPushed:(id)sender
{
    [self loadHatenaBookmark];
}

-(IBAction)addBookmarkButtonPushed:(id)sender
{
    // iOS 6 or later
    if ([UIActivityViewController class]) {
        HTBHatenaBookmarkActivity *hateaBookmarkActivity = [[HTBHatenaBookmarkActivity alloc] init];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[_webView.request.URL]                                                                               applicationActivities:@[hateaBookmarkActivity]];
        [self presentViewController:activityView animated:YES completion:nil];
    }
    else {
        HTBHatenaBookmarkViewController *viewController = [[HTBHatenaBookmarkViewController alloc] init];
        viewController.URL = _webView.request.URL;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

-(void)showOAuthLoginView:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTBLoginStartNotification object:nil];
    
    NSURLRequest *req = (NSURLRequest *)notification.object;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[HTBNavigationBar class] toolbarClass:nil];
    HTBLoginWebViewController *viewController = [[HTBLoginWebViewController alloc] initWithAuthorizationRequest:req];
    navigationController.viewControllers = @[viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)loginButtonPushed:(id)sender
{
#ifdef AUTOMATION
    [[HTBAutomationHelper sharedHelper] login:^{
        [self toggleLoginButtons];
    }];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOAuthLoginView:) name:kHTBLoginStartNotification object:nil];
    
    [[HTBHatenaBookmarkManager sharedManager] logout];
    [[HTBHatenaBookmarkManager sharedManager] authorizeWithSuccess:^{
        [self toggleLoginButtons];
    } failure:^(NSError *error) {
    }];
#endif
}

- (IBAction)logoutButtonPushed:(id)sender
{
#ifdef AUTOMATION
    [[HTBAutomationHelper sharedHelper] logout];
#else
    [[HTBHatenaBookmarkManager sharedManager] logout];
    [self toggleLoginButtons];
//    self.navigationItem.rightBarButtonItem.enabled = [HTBHatenaBookmarkManager sharedManager].authorized;
#endif
}

- (void)initializeHatenaBookmarkClient {
    [[HTBHatenaBookmarkManager sharedManager] setConsumerKey:@"your consumer key" consumerSecret:@"your consumer secret"];
    if ([HTBHatenaBookmarkManager sharedManager].authorized) {
        [[HTBHatenaBookmarkManager sharedManager] getMyEntryWithSuccess:^(HTBMyEntry *myEntry) {

        } failure:^(NSError *error) {

        }];
        [[HTBHatenaBookmarkManager sharedManager] getMyTagsWithSuccess:^(HTBMyTagsEntry *myTagsEntry) {

        } failure:^(NSError *error) {

        }];
    }
}

- (void)toggleLoginButtons
{
    if ([HTBHatenaBookmarkManager sharedManager].authorized) {
        [self showLogoutButton];
    }
    else {
        [self showLoginButton];
    }
}

- (void)showLoginButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonPushed:)];
        self.navigationController.toolbar.items = @[item];
    });
}

- (void)showLogoutButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPushed:)];
        self.navigationController.toolbar.items = @[item];
    });
}

@end
