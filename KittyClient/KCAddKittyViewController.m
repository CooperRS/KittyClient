//
//  AddKittyViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCAddKittyViewController.h"

#import "KCKittyManager.h"
#import "AFHTTPRequestOperation.h"

@interface KCAddKittyViewController ()

@property (nonatomic, strong) IBOutlet UITextField *textField;

@end

@implementation KCAddKittyViewController

#pragma mark - Actions
- (IBAction)addButtonTapped:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"kitty", self.textField.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        [[KCKittyManager sharedKittyManager] addKitty:responseObject];
        [self.delegate addKittyVCDidFinish:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong Kitty ID?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

@end
