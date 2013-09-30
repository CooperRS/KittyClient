//
//  DrinkTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyDrinkTableViewController.h"

#import "KCKittyDrinkCell.h"

#import "KCKittyManager.h"
#import "AFHTTPRequestOperation.h"

@interface KCKittyDrinkTableViewController () <KCKittyDrinkCellDelegate>

@property (nonatomic, strong) NSDictionary *kitty;
@property (nonatomic, strong) NSMutableArray *drinks;

@end

@implementation KCKittyDrinkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.drinks = [NSMutableArray array];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@ EUR)", [self.user objectForKey:@"name"], [self.user objectForKey:@"money"]];
    
#warning MBProgressHUD here!
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"userItems", [self.user objectForKey:@"userId"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *newDrinks = [NSMutableArray array];
        for (NSDictionary *aDrink in responseObject) {
            [newDrinks addObject:aDrink];
        }
        
        self.drinks = newDrinks;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
#warning Rework error messages
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong Kitty ID?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - Properties
- (NSDictionary *)kitty {
    return [[KCKittyManager sharedKittyManager] kittyAtIndex:self.selectedKittyIndex];
}

- (NSMutableArray *)drinks {
    if(!_drinks) {
        self.drinks = [NSMutableArray array];
    }
    
    return _drinks;
}

#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.drinks count];
}

static NSString *CellIdentifier = @"DrinkCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCKittyDrinkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    KCKittyDrinkCell *aCell = cell;
    
    NSURL *URL;
    if (aCell.stepper.value == 2)
        URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"incItem", [NSNumber numberWithInteger:aCell.tag] ]];
    if (aCell.stepper.value == 0)
        URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"decItem", [NSNumber numberWithInteger:aCell.tag] ]];
    
    //NSLog(@"%@", URL);
        
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        aCell.itemCount.text = [[responseObject objectForKey:@"itemCount"] stringValue];
        aCell.stepper.value = 1;
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@ EUR)", [self.user objectForKey:@"name"], [responseObject objectForKey:@"userMoney"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
#warning Rework error messages
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"Wrong Kitty ID?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
