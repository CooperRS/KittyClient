//
//  DrinkTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "DrinkTableViewController.h"
#import "AFHTTPRequestOperation.h"
#import "DrinkTableViewCell.h"

@interface DrinkTableViewController () <DrinkTableViewCellDelegate>

@end

@implementation DrinkTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.drinks = [NSMutableArray array];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@ EUR)", [self.aUser objectForKey:@"name"], [self.aUser objectForKey:@"money"]];
    [self loadDrinks];
}

- (void) loadDrinks
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"userItems", [self.aUser objectForKey:@"userId"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for (NSDictionary* jsonDrinks in responseObject) {
            [self.drinks addObject:jsonDrinks];
        }
        [self.tableView reloadData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.drinks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    DrinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary* aDrink = [self.drinks objectAtIndex:indexPath.row];
    cell.itemName.text = [aDrink objectForKey:@"itemName"];
    cell.itemPrice.text = [NSString stringWithFormat:@"(%@ EUR)",[aDrink objectForKey:@"itemPrice"] ];
    cell.itemCount.text = [[aDrink objectForKey:@"itemCount"] stringValue];
    cell.tag = [[aDrink objectForKey:@"itemId"] integerValue];
    cell.delegate = self;
    
    return cell;
}

#pragma mark delegates
- (void)changeItemCountForCell:(id)cell {
    DrinkTableViewCell *aCell = cell;
    
    NSURL *URL;
    if (aCell.stepper.value == 2)
        URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"incItem", [NSNumber numberWithInteger:aCell.tag] ]];
    if (aCell.stepper.value == 0)
        URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"decItem", [NSNumber numberWithInteger:aCell.tag] ]];
    
    NSLog(@"%@", URL);
        
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        aCell.itemCount.text = [[responseObject objectForKey:@"itemCount"] stringValue];
        aCell.stepper.value = 1;
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@ EUR)", [self.aUser objectForKey:@"name"], [responseObject objectForKey:@"userMoney"]];
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
