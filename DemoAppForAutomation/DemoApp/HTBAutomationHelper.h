//
//  HTBAutomationHelper.h
//  DemoApp
//
//  Created by giginet on 8/29/13.
//  Copyright (c) 2013 Hatena Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTBAutomationHelper : NSObject

+ (instancetype)sharedHelper;
- (BOOL)setupForAutomation;
- (void)stubAllRequests;
- (void)login:(void (^)(void))success;
- (void)logout;

@end
