//
//  DrinkTableViewController.h
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *aKitty;
@property (nonatomic, strong) NSDictionary *aUser;
@property (nonatomic, strong) NSMutableArray *drinks;

@end
