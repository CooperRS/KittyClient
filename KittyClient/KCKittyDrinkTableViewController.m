//
//  DrinkTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyDrinkTableViewController.h"
#import "MBProgressHUD.h"

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
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@ €)", [self.user objectForKey:@"name"], [self.user objectForKey:@"money"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"userItems", [self.user objectForKey:@"userId"]]];
    //NSLog(@"URL: %@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *newDrinks = [NSMutableArray array];
        for (NSDictionary *aDrink in responseObject) {
            [newDrinks addObject:aDrink];
        }
        self.drinks = newDrinks;
        
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Beim Laden der Getränke ist ein Fehler passiert. Bitte erneut versuchen." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    cell.itemPrice.text = [NSString stringWithFormat:@"(%.2f €)", [[aDrink objectForKey:@"itemPrice"] doubleValue]];
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
    
    NSLog(@"%@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Laden..";
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        aCell.itemCount.text = [[responseObject objectForKey:@"itemCount"] stringValue];
        aCell.stepper.value = 1;
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%.2f €)", [self.user objectForKey:@"name"], [[responseObject objectForKey:@"userMoney"] doubleValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler"  message:@"Beim Setzen der Anzahl getrunkener Getränke ist ein Fehler passiert. Bitte erneut versuchen." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
