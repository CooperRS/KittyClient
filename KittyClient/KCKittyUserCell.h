//
//  KCKittyUserCell.h
//  KittyClient
//
//  Created by Roland Moers on 30.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCKittyUserCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *balanceLabel;

@property (nonatomic, weak) IBOutlet UIButton *infoButton;

@end
