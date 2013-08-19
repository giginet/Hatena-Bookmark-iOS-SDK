//  HTBBookmarkViewController.m
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

#import "HTBBookmarkViewController.h"
#import "HTBToggleButton.h"
#import "UIImageView+AFNetworking.h"
#import "HTBTagTokenizer.h"
#import "HTBBookmarkEntryView.h"
#import "HTBCommentViewController.h"
#import "HTBBookmarkToolbarView.h"
#import "HTBUserManager.h"
#import "HTBTagToolbarView.h"
#import "HTBTagTextField.h"
#import "HTBHatenaBookmarkManager.h"
#import "HTBMyEntry.h"
#import "HTBBookmarkEntry.h"
#import "HTBBookmarkedDataEntry.h"
#import "HTBPlaceholderTextView.h"
#import "HTBUtility.h"
#import "HTBBookmarkRootView.h"
#import "HTBMyTagsEntry.h"
#import "HTBCanonicalEntry.h"
#import "HTBCanonicalView.h"
#import "UIAlertView+HTBNSError.h"

@interface HTBBookmarkViewController ()
@property (nonatomic, strong) HTBBookmarkEntry *entry;
@property (nonatomic, strong) HTBCanonicalEntry *canonicalEntry;
@property (nonatomic, strong) HTBBookmarkRootView *rootView;
@end

@implementation HTBBookmarkViewController {
    BOOL _entryRequestFinised;
    BOOL _canonicalRequestFinished;
}

-(void)loadView
{
    [super loadView];
    self.rootView = [[HTBBookmarkRootView alloc] initWithFrame:CGRectZero];
    self.rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = self.rootView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [HTBUtility localizedStringForKey:@"hatena-bookmark" withDefault:@"Hatena Bookmark"] : [HTBUtility localizedStringForKey:@"bookmark" withDefault:@"Bookmark"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[HTBUtility localizedStringForKey:@"back" withDefault:@"Back"] style: UIBarButtonItemStyleBordered target:nil action:nil];

    [[HTBHatenaBookmarkManager sharedManager] getBookmarkEntryWithURL:self.URL success:^(HTBBookmarkEntry *entry) {
        _entryRequestFinised = YES;
        [self setEntry:entry];
        [self handleCanonicalURL];
        [self.rootView.bookmarkActivityIndicatorView stopAnimating];
    } failure:^(NSError *error) {
        [self handleHTTPError:error];

        _entryRequestFinised = YES;
        [self handleCanonicalURL];
        // handle auth
        [self.rootView.bookmarkActivityIndicatorView stopAnimating];
    }];

    [[HTBHatenaBookmarkManager sharedManager] getCanonicalEntryWithURL:self.URL success:^(HTBCanonicalEntry *entry) {
        _canonicalRequestFinished = YES;
        _canonicalEntry = entry;
        [self handleCanonicalURL];
        if (entry.canonicalURL) {
            [self getBookmarkedEntryWithURL:entry.canonicalURL success:^(HTBBookmarkedDataEntry *bookmarked) {
                if (bookmarked) {
                    self.URL = entry.canonicalURL;
                } else {
                    [self.rootView.myBookmarkActivityIndicatorView startAnimating];
                    [self getBookmarkedEntryWithURL:self.URL success:nil];
                }
            }];
        } else {
            [self getBookmarkedEntryWithURL:self.URL success:nil];
        }
    } failure:^(NSError *error) {
        [self handleHTTPError:error];
        _canonicalRequestFinished = YES;
        [self handleCanonicalURL];
        // handle auth
    }];

    if ([HTBUserManager sharedManager].myEntry) {
        self.rootView.toolbarView.myEntry = [HTBUserManager sharedManager].myEntry;
    }
    else {
        [[HTBHatenaBookmarkManager sharedManager] getMyEntryWithSuccess:^(HTBMyEntry *myEntry) {
            self.rootView.toolbarView.myEntry = myEntry;
        } failure:^(NSError *error) {
            [self handleHTTPError:error];
        }];
    }
    if ([HTBUserManager sharedManager].myTagsEntry) {
        self.rootView.tagTextField.myTags = [[HTBUserManager sharedManager].myTagsEntry.sortedTags valueForKeyPath:@"tag"];
    }
    else {
        [[HTBHatenaBookmarkManager sharedManager] getMyTagsWithSuccess:^(HTBMyTagsEntry *myTagsEntry) {
            self.rootView.tagTextField.myTags = [myTagsEntry.sortedTags valueForKeyPath:@"tag"];
        } failure:^(NSError *error) {
            [self handleHTTPError:error];
        }];
    }

    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[HTBUtility localizedStringForKey:@"close" withDefault:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonPushed:)];
    }

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:[HTBUtility localizedStringForKey:@"add" withDefault:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addBookmarkButtonPushed:)];
    self.navigationItem.rightBarButtonItems = @[addButton];

    [self.rootView.entryView addTarget:self action:@selector(entryButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView.canonicalView addTarget:self action:@selector(canonicalButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleHTTPError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithHTBError:error];
        [alertView addButtonWithTitle:[HTBUtility localizedStringForKey:@"cancel" withDefault:@"Cancel"]];
        [alertView show];
    });
}

- (void)handleCanonicalURL
{
    if (_entryRequestFinised && _canonicalRequestFinished) {
        BOOL canonicalURLDetected = self.entry.URL && self.canonicalEntry.canonicalURL && ![[self.canonicalEntry.canonicalURL absoluteString] isEqualToString:[self.entry.URL absoluteString]];
        BOOL entryMissingButCanonicalDetected = !self.entry.count && self.canonicalEntry.canonicalURL && ![[self.canonicalEntry.canonicalURL absoluteString] isEqualToString:[self.URL absoluteString]];
        if (canonicalURLDetected || entryMissingButCanonicalDetected) {
            [self.rootView setCanonicalViewShown:YES urlString:self.canonicalEntry.displayCanonicalURLString animated:YES];
        }

    }
}

- (void)canonicalButtonPushed:(id)sender
{
    HTBBookmarkViewController *viewController = [[HTBBookmarkViewController alloc] init];
    viewController.URL = _canonicalEntry.canonicalURL;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)entryButtonPushed:(id)sender
{
    HTBCommentViewController *viewController = [[HTBCommentViewController alloc] init];
    viewController.entry = self.entry;
    [self.navigationController pushViewController:viewController animated:YES];
    [self.rootView.commentTextView resignFirstResponder];
    [self.rootView.tagTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.rootView.commentTextView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed]) {
        CGRect frame = self.parentViewController.view.frame;
        frame.origin.y = self.view.window.bounds.size.height;
        [UIView animateWithDuration:animated ? 0.27 : 0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.parentViewController.view.frame = frame;
        } completion:nil];
    }
}

- (void)setEntry:(HTBBookmarkEntry *)entry
{
    if (entry) {
        _entry = entry;
        self.rootView.entryView.entry = entry;
        self.rootView.tagTextField.recommendedTags = entry.recommendTags;
    }
}

-(void)setBookmarkedDataEntry:(HTBBookmarkedDataEntry *)entry
{
    if (entry) {
        self.rootView.commentTextView.text = entry.comment;
        self.rootView.tagTextField.text = [HTBTagTokenizer tagArrayToSpaceText:entry.tags];
        self.rootView.toolbarView.bookmarkEntry = entry;

        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:[HTBUtility localizedStringForKey:@"edit" withDefault:@"Edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(addBookmarkButtonPushed:)];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle: [HTBUtility localizedStringForKey:@"delete" withDefault:@"Delete"] style:UIBarButtonItemStyleBordered target:self action:@selector(deleteBookmarkButtonPushed:)];
        self.navigationItem.rightBarButtonItems = @[editButton, deleteButton];
    }
}

- (IBAction)addBookmarkButtonPushed:(id)sender
{
    [self.rootView.myBookmarkActivityIndicatorView startAnimating];
    NSArray *tags = [HTBTagTokenizer spaceTextToTagArray:self.rootView.tagTextField.text];

    HatenaBookmarkPOSTOptions options = HatenaBookmarkPostOptionNone;
    
    if (self.rootView.toolbarView.twitterToggleButton.selected) {
        options |= HatenaBookmarkPostOptionTwitter;
    }
    if (self.rootView.toolbarView.facebookToggleButton.selected) {
        options |= HatenaBookmarkPostOptionFacebook;
    }
    if (self.rootView.toolbarView.mixiToggleButton.selected) {
        options |= HatenaBookmarkPostOptionMixi;
    }
    if (self.rootView.toolbarView.mailToggleButton.selected) {
        options |= HatenaBookmarkPostOptionSendMail;
    }
    if (self.rootView.toolbarView.evernoteToggleButton.selected) {
        options |= HatenaBookmarkPostOptionEvernote;
    }
    if (self.rootView.toolbarView.privateToggleButton.selected) {
        options |= HatenaBookmarkPostOptionPrivate;
    }
    [[HTBHatenaBookmarkManager sharedManager] postBookmarkWithURL:self.URL comment:self.rootView.commentTextView.text tags:tags options:options success:^(HTBBookmarkedDataEntry *entry) {
        [self setBookmarkedDataEntry:entry];
        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [self handleHTTPError:error];
        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
    }];
}

- (IBAction)deleteBookmarkButtonPushed:(id)sender
{
    [self.rootView.myBookmarkActivityIndicatorView startAnimating];
    [[HTBHatenaBookmarkManager sharedManager] deleteBookmarkWithURL:self.URL success:^{
        self.rootView.commentTextView.text = nil;
        self.rootView.tagTextField.text = nil;
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:[HTBUtility localizedStringForKey:@"add" withDefault:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addBookmarkButtonPushed:)];
        self.navigationItem.rightBarButtonItems = @[addButton];
        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [self handleHTTPError:error];
        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
    }];
}

- (IBAction)closeButtonPushed:(id)sender
{
    [self.rootView.commentTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getBookmarkedEntryWithURL:(NSURL *)url success:(void (^)(HTBBookmarkedDataEntry *entry))success
{
    [[HTBHatenaBookmarkManager sharedManager] getBookmarkedDataEntryWithURL:url success:^(HTBBookmarkedDataEntry *entry) {
        [self setBookmarkedDataEntry:entry];
        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
        if (success) success(entry);
    } failure:^(NSError *error) {
        [self handleHTTPError:error];

        [self.rootView.myBookmarkActivityIndicatorView stopAnimating];
    }];
}

@end
