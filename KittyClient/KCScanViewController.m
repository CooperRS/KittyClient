//
//  ViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
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
        [sender setTitle:@"Blitz aus"];
    } else {
        [self.sessionManager.captureSession beginConfiguration];
        if([self.sessionManager.videoDevice lockForConfiguration:nil]) {
            [self.sessionManager.videoDevice setTorchMode:AVCaptureTorchModeOff];
            [self.sessionManager.videoDevice setFlashMode:AVCaptureFlashModeOff];
            [self.sessionManager.videoDevice unlockForConfiguration];
        }
        
        [self.sessionManager.captureSession commitConfiguration];
        [sender setTitle:@"Blitz an"];
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
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit dieser ID wurde bereits hinzugefügt. Sie ist unter den Einstellungen zu finden." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [theAlert show];
            
            return;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"kitty", enteredKittyID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        [[KCKittyManager sharedKittyManager] addKitty:responseObject];
        
        NSString *message = [NSString stringWithFormat:@"Die Kitty \"%@\" wurde erfolgreich hinzugefügt. Sie können nun unter Einstellungen einen User auswählen.", responseObject[@"name"]];
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit der eingegebenen ID konnte nicht gefunden werden. Bitte die eingegebene ID überprüfen." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"userItems", [KCKittyManager sharedKittyManager].selectedUserID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        BOOL foundEAN = NO;
        for(NSDictionary *aUserItem in responseObject) {
            if([[aUserItem objectForKey:@"itemEAN"] isKindOfClass:[NSString class]] && [[aUserItem objectForKey:@"itemEAN"] isEqualToString:eanCode]) {
                self.currentUserItem = aUserItem;
                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Wollen Sie das folgende Getränk kaufen?\n\n%@\nEAN Code: %@", [aUserItem objectForKey:@"itemName"], eanCode] delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:@"Kaufen", nil];
                [sheet showInView:self.view];
                
                foundEAN = YES;
                break;
            }
        }
        
        if(!foundEAN) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler"  message:@"Dieses Getränk ist in der ausgewählten Kitty unbekannt." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [theAlert show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Beim Laden der verfügbaren Getränke ist ein Fehler passiert. Ist unter den Einstellungen eine Kitty und ein Benutzer ausgewählt?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

#pragma mark UIActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != [actionSheet cancelButtonIndex]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Laden..";
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"incItem", [self.currentUserItem objectForKey:@"itemId"]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Erfolg" message:@"Der Getränk wurde erfolgreich gekauft. Viel Spaß damit!" delegate:self cancelButtonTitle:@"Danke" otherButtonTitles:nil];
            [theAlert show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler"  message:@"Beim Kaufen des Getränkes ist ein fehler passiert. Bitte erneut versuchen." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
