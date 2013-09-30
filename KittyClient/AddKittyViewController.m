//
//  AddKittyViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 25.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "AddKittyViewController.h"
#import "AFHTTPRequestOperation.h"

@interface AddKittyViewController ()
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction) clickCancel: (id) sender;
- (IBAction) clickAdd:(id)sender;
@end

@implementation AddKittyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions
- (void)clickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickAdd:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"kitty", self.textField.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [self.delegate addValidKitty:responseObject];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"Wrong Kitty ID?"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
