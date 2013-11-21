//
//  DrinkTableViewController.m
//  KittyClient
//
//  Created by Roland Moers on 27.09.13.
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
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%.2f €)", [self.user objectForKey:@"name"], [[self.user objectForKey:@"money"] doubleValue]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"userItems", [self.user objectForKey:@"userId"]]];
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
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured while loading all drinks. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"Drinks", nil);
    }
    
    return @"";
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
        URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"incItem", [NSNumber numberWithInteger:aCell.tag] ]];
    if (aCell.stepper.value == 0)
        URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"decItem", [NSNumber numberWithInteger:aCell.tag] ]];
    
    //NSLog(@"%@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        aCell.itemCount.text = [[responseObject objectForKey:@"itemCount"] stringValue];
        aCell.stepper.value = 1;
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%.2f €)", [self.user objectForKey:@"name"], [[responseObject objectForKey:@"userMoney"] doubleValue]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)  message:NSLocalizedString(@"An error occured while settings the number of bought drinks. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [theAlert show];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
