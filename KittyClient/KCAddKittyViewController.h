//
//  AddKittyViewController.h
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KCAddKittyViewController;

@protocol KCAddKittyViewControllerDelegate <NSObject>

- (void)addKittyVCDidFinish:(KCAddKittyViewController *)addKittyVC;
- (void)addKittyVCDidCancel:(KCAddKittyViewController *)addKittyVC;

@end

@interface KCAddKittyViewController : UITableViewController

@property (nonatomic, weak) id<KCAddKittyViewControllerDelegate> delegate;

@end
