//
//  KCKittyManager.h
//  KittyClient
//
//  Created by Roland Moers on 30.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCKittyManager : NSObject

@property (readonly) NSNumber *selectedKittyID;
@property (readonly) NSNumber *selectedUserID;

@property (nonatomic, readonly) NSArray *kitties;

+ (instancetype)sharedKittyManager;

- (void)setSelectedKittyID:(NSInteger)kittyID andUserID:(NSInteger)userID;

- (void)addKitty:(NSDictionary *)newKitty;
- (NSDictionary *)kittyAtIndex:(NSInteger)index;
- (void)replaceKittyAtIndex:(NSInteger)index withKitty:(NSDictionary *)newKitty;
- (void)removeKittyAtIndex:(NSInteger)index;

- (void)save;

@end
