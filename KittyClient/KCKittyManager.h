//
//  KCKittyManager.h
//  KittyClient
//
//  Created by Roland Moers on 30.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCKittyManager : NSObject

@property (readonly) NSString *serverURL;
@property (nonatomic, strong) NSString *serverBaseURL;

@property (readonly) NSString *selectedKittyID;
@property (readonly) NSNumber *selectedUserID;

@property (nonatomic, readonly) NSArray *kitties;

+ (instancetype)sharedKittyManager;

- (void)setSelectedKittyID:(NSString *)kittyID andUserID:(NSNumber *)userID;

- (void)addKitty:(NSDictionary *)newKitty;
- (NSDictionary *)kittyAtIndex:(NSInteger)index;
- (void)replaceKittyAtIndex:(NSInteger)index withKitty:(NSDictionary *)newKitty;
- (void)removeKittyAtIndex:(NSInteger)index;
- (void)removeAllKitties;

- (void)save;

@end
