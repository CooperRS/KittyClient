//
//  AddKittyViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCAddKittyViewController.h"
#import "MBProgressHUD.h"

#import "KCKittyManager.h"
#import "AFHTTPRequestOperation.h"

@interface KCAddKittyViewController () <UISearchBarDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textField;

@end

@implementation KCAddKittyViewController

#pragma mark - Actions
- (IBAction)addButtonTapped:(id)sender {
    NSString *enteredKittyID = self.textField.text;
    for(NSDictionary *aKitty in [KCKittyManager sharedKittyManager].kitties) {
        if([[enteredKittyID capitalizedString] isEqualToString:[aKitty[@"kittyId"] capitalizedString]]) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit dieser ID wurde bereits hinzugefügt. Bitte eine andere ID eingeben." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [theAlert show];
            
            return;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"kitty", enteredKittyID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        [[KCKittyManager sharedKittyManager] addKitty:responseObject];
        [self.delegate addKittyVCDidFinish:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Eine Kitty mit der eingegebenen ID konnte nicht gefunden werden. Bitte die eingegebene ID überprüfen." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate addKittyVCDidCancel:self];
}

#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 1) {
        [self addButtonTapped:nil];
    }
}

#pragma mark - UITextField Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self addButtonTapped:textField];
    
    return YES;
}

@end
