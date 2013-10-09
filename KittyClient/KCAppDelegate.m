//
//  AppDelegate.m
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCAppDelegate.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

#import "KCKittyManager.h"

@implementation KCAppDelegate

#pragma mark - Helper
- (BOOL)isKittyURL:(NSURL *)anURL {
    return [[anURL scheme] isEqualToString:@"kitty"] && [[anURL absoluteString] length] > 8;
}

- (void)processKittyURL:(NSURL *)anURL {
    NSString *enteredKittyID = [[anURL absoluteString] substringFromIndex:8];
    for(NSDictionary *aKitty in [KCKittyManager sharedKittyManager].kitties) {
        if([[enteredKittyID capitalizedString] isEqualToString:[aKitty[@"kittyId"] capitalizedString]]) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit dieser ID wurde bereits hinzugefügt. Sie ist unter den Einstellungen zu finden." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [theAlert show];
            
            return;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"kitty", enteredKittyID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:YES];
        
        [[KCKittyManager sharedKittyManager] addKitty:responseObject];
        
        NSString *message = [NSString stringWithFormat:@"Die Kitty \"%@\" wurde erfolgreich hinzugefügt. Sie können nun unter Einstellungen einen User auswählen.", responseObject[@"name"]];
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit der eingegebenen ID konnte nicht gefunden werden. Bitte die eingegebene ID überprüfen." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - UIApplication Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if([self isKittyURL:url]) {
        [self processKittyURL:url];
        
        return YES;
    }
    
    return NO;
}

@end
