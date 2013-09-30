//
//  DrinkTableViewCell.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyDrinkCell.h"

@implementation KCKittyDrinkCell

- (void)valueChanged:(id)sender {
    [self.delegate changeItemCountForCell:self];
}

@end
