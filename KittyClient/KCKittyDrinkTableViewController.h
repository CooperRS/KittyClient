//
//  DrinkTableViewController.h
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCKittyDrinkTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger selectedKittyIndex;
@property (nonatomic, strong) NSDictionary *user;

@end
