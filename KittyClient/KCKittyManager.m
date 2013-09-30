//
//  KCKittyManager.m
//  KittyClient
//
//  Created by Roland Moers on 30.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyManager.h"

@interface KCKittyManager ()

@property (nonatomic, strong) NSMutableArray *mutableKitties;

@end

@implementation KCKittyManager

#pragma mark - Class methods
static KCKittyManager *sharedKittyManager = nil;
+ (instancetype)sharedKittyManager {
    @synchronized(self) {
        if(!sharedKittyManager)
            sharedKittyManager = [[KCKittyManager alloc] init];
    }
    
    return sharedKittyManager;
}

#pragma Settings
- (NSNumber *)selectedKitty {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kittyID"];
}

- (NSNumber *)selectedUserID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
}

- (void)setSelectedKittyID:(NSInteger)kittyID andUserID:(NSInteger)userID {
    [[NSUserDefaults standardUserDefaults] setInteger:kittyID forKey:@"kittyID"];
    [[NSUserDefaults standardUserDefaults] setInteger:userID forKey:@"userID"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Kitties
- (NSMutableArray *)mutableKitties {
    if(!_mutableKitties) {
        NSData *archivedKitties = [[NSUserDefaults standardUserDefaults] objectForKey:@"mutableKitties"];
        NSArray *immutableKitties = nil;
        
        @try {
            immutableKitties = [NSKeyedUnarchiver unarchiveObjectWithData:archivedKitties];
        }
        @catch (NSException *exception) {
        }
        
        if(!immutableKitties) {
            immutableKitties = [NSArray array];
        }
        
        self.mutableKitties = [immutableKitties mutableCopy];
    }
    
    return _mutableKitties;
}

- (NSArray *)kitties {
    return self.mutableKitties;
}

- (NSDictionary *)kittyAtIndex:(NSInteger)index {
    return [self.mutableKitties objectAtIndex:index];
}

- (void)addKitty:(NSDictionary *)newKitty {
    [self.mutableKitties addObject:newKitty];
    
    [self save];
}

- (void)replaceKittyAtIndex:(NSInteger)index withKitty:(NSDictionary *)newKitty {
    [self.mutableKitties replaceObjectAtIndex:index withObject:newKitty];
    
    [self save];
}

- (void)removeKittyAtIndex:(NSInteger)index {
    [self.mutableKitties removeObjectAtIndex:index];
    
    if(self.selectedKittyID && index == [self.selectedKittyID integerValue]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kittyID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userID"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self save];
}

#pragma mark - Save
- (void)save {
    NSData *archivedKitties = [NSKeyedArchiver archivedDataWithRootObject:self.mutableKitties];
    [[NSUserDefaults standardUserDefaults] setObject:archivedKitties forKey:@"mutableKitties"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
