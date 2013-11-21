//
//  ViewController.m
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

#import "KCScanViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

#import "KCKittyManager.h"
#import "SessionManager.h"

@interface KCScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) SessionManager *sessionManager;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) NSDictionary *currentUserItem;
@property (nonatomic, assign) BOOL canRecognizeCodes;

@end

@implementation KCScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [[SessionManager alloc] init];
	[self.sessionManager startRunning];
	[self.sessionManager.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.captureSession];
	[previewLayer setFrame:self.view.frame];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.view.layer insertSublayer:previewLayer atIndex:0];
	[self.view.layer setMasksToBounds:YES];
	[self setPreviewLayer:previewLayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.canRecognizeCodes = YES;
}

#pragma mark - Orientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    if ([[self.previewLayer connection] isVideoOrientationSupported]) {
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            [[self.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [[self.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        } else if(toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [[self.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
	}
    [CATransaction commit];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [self.previewLayer setFrame:self.view.frame];
    [CATransaction commit];
}

#pragma mark - Actions
- (IBAction)flashButtonTapped:(UIBarButtonItem *)sender {
    if(!self.sessionManager.videoDevice.flashActive) {
        [self.sessionManager.captureSession beginConfiguration];
        if([self.sessionManager.videoDevice lockForConfiguration:nil]) {
            [self.sessionManager.videoDevice setTorchMode:AVCaptureTorchModeOn];
            [self.sessionManager.videoDevice setFlashMode:AVCaptureFlashModeOn];
            [self.sessionManager.videoDevice unlockForConfiguration];
        }
        
        [self.sessionManager.captureSession commitConfiguration];
        [sender setTitle:NSLocalizedString(@"Flash off", nil)];
    } else {
        [self.sessionManager.captureSession beginConfiguration];
        if([self.sessionManager.videoDevice lockForConfiguration:nil]) {
            [self.sessionManager.videoDevice setTorchMode:AVCaptureTorchModeOff];
            [self.sessionManager.videoDevice setFlashMode:AVCaptureFlashModeOff];
            [self.sessionManager.videoDevice unlockForConfiguration];
        }
        
        [self.sessionManager.captureSession commitConfiguration];
        [sender setTitle:NSLocalizedString(@"Flash on", nil)];
    }
}

#pragma mark - Helper
- (BOOL)isKittyURL:(NSURL *)anURL {
    return [[anURL scheme] isEqualToString:@"kitty"] && [[anURL absoluteString] length] > 8;
}

- (void)processKittyURL:(NSURL *)anURL {
    self.canRecognizeCodes = NO;
    
    NSString *enteredKittyID = [[anURL absoluteString] substringFromIndex:8];
    for(NSDictionary *aKitty in [KCKittyManager sharedKittyManager].kitties) {
        if([[enteredKittyID capitalizedString] isEqualToString:[aKitty[@"kittyId"] capitalizedString]]) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Another Kitty with the same ID has already been added. You can find it in the settings.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [theAlert show];
            
            return;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"kitty", enteredKittyID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        [[KCKittyManager sharedKittyManager] addKitty:responseObject];
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The kitty \"%@\" has been added successfully. You can now choose an user in the settings.", nil), responseObject[@"name"]];
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [theAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"A kitty with the scanned ID could not be found. Please check your server URL.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (BOOL)isEANCode:(NSString *)aCode {
    return ([aCode length] == 8 || [aCode length] == 13) && [aCode rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
}

- (void)processEANCode:(NSString *)eanCode {
    self.canRecognizeCodes = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"users", [KCKittyManager sharedKittyManager].selectedKittyID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL foundUser = NO;
        for(NSDictionary *aUser in responseObject) {
            if([[aUser objectForKey:@"userId"] isEqualToNumber:[KCKittyManager sharedKittyManager].selectedUserID]) {
                NSLog(@"Found User: %@", aUser);
                
                NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"userItems", [KCKittyManager sharedKittyManager].selectedUserID]];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                
                AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                op.responseSerializer = [AFJSONResponseSerializer serializer];
                [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                    
                    BOOL foundEAN = NO;
                    for(NSDictionary *aUserItem in responseObject) {
                        if([[aUserItem objectForKey:@"itemEAN"] isKindOfClass:[NSString class]] && [[aUserItem objectForKey:@"itemEAN"] isEqualToString:eanCode]) {
                            //NSLog(@"Found Item: %@", aUserItem);
                            
                            self.currentUserItem = aUserItem;
                            
                            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Do you want to buy the following drink?˜n\n%@\nEAN: %@\nPrice: %.2f €\n\nUser: %@\nBalance: %.2f €", nil), [aUserItem objectForKey:@"itemName"], eanCode, [aUserItem[@"itemPrice"] doubleValue], aUser[@"name"], [aUser[@"money"] doubleValue]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Buy", nil), nil];
                            [sheet showInView:self.view];
                            
                            foundEAN = YES;
                            break;
                        }
                    }
                    
                    if(!foundEAN) {
                        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)  message:NSLocalizedString(@"The scanned drink is unknown in the chosen kitty.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [theAlert show];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                    
                    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured while loading the available drinks. Did you choose a kitty and a user in settings?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [theAlert show];
                }];
                [[NSOperationQueue mainQueue] addOperation:op];
                
                foundUser = YES;
                break;
            }
        }
        
        if(!foundUser) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)  message:NSLocalizedString(@"The chosen user is not registered in the chosen kitty.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [theAlert show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured while loading the available users. Did you choose a kitty in settings?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - Barcodes
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if(self.canRecognizeCodes) {
        AVMetadataObject *anObject = [metadataObjects lastObject];
        if(anObject && [anObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *aReadableObject = (AVMetadataMachineReadableCodeObject *)anObject;
            
            if([self isKittyURL:[NSURL URLWithString:aReadableObject.stringValue]]) {
                [self processKittyURL:[NSURL URLWithString:aReadableObject.stringValue]];
            } else if([self isEANCode:aReadableObject.stringValue] && [KCKittyManager sharedKittyManager].selectedKittyID && [KCKittyManager sharedKittyManager].selectedUserID) {
                [self processEANCode:aReadableObject.stringValue];
            }
        }
    }
}

#pragma mark - UIActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != [actionSheet cancelButtonIndex]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"Loading...", nil);
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"incItem", [self.currentUserItem objectForKey:@"itemId"]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"JSON: %@", responseObject);
            
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"The drinks has been bought successfully. Your new Balance is %.2f. Have fun with it!", nil), [responseObject[@"userMoney"] doubleValue]];
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Thanks", nil) otherButtonTitles:nil];
            [theAlert show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)  message:NSLocalizedString(@"An error occured while buying the drink. Please try again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [theAlert show];
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    } else {
        self.canRecognizeCodes = YES;
    }
}

#pragma mark - UIAlertViewDelegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.canRecognizeCodes = YES;
}

@end
