//
//  DrinkTableViewCell.h
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrinkTableViewCellDelegate <NSObject>

- (void) changeItemCountForCell: (id) cell;

@end

@interface DrinkTableViewCell : UITableViewCell

@property (nonatomic, weak) id <DrinkTableViewCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *itemPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemCount;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;

- (IBAction)valueChanged:(id)sender;

@end
