//
//  AddKittyViewController.h
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddKittyViewControllerDelegate <NSObject>

- (void) addValidKitty: (NSDictionary*) jsonResponse;

@end

@interface AddKittyViewController : UIViewController

@property(nonatomic, weak) id <AddKittyViewControllerDelegate> delegate;

@end
