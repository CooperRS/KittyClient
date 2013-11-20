//
//  AppDelegate.m
//  KittyClient
//
//  Created by Roland Moers on 25.09.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"kitty", enteredKittyID]];
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
