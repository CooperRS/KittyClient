//
//  UserTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyUserTableViewController.h"

#import "KCKittyDrinkTableViewController.h"

#import "KCKittyUserCell.h"

#import "KCKittyManager.h"
#import "AFHTTPRequestOperation.h"

@interface KCKittyUserTableViewController ()

@property (nonatomic, strong) NSDictionary *kitty;
@property (nonatomic, strong) NSMutableArray *users;

@end

@implementation KCKittyUserTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#warning MBProgressHUD here!
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:BASE_API_URL, @"users", [self.kitty objectForKey:@"kittyId"] ]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *newUsers = [NSMutableArray array];
        for (NSDictionary *aUser in responseObject) {
            [newUsers addObject:aUser];
        }
        self.users = newUsers;
        
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

- (void)setKitty:(NSDictionary *)newKitty {
    [[KCKittyManager sharedKittyManager] replaceKittyAtIndex:self.selectedKittyIndex withKitty:newKitty];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)users {
    if(!_users) {
        self.users = [NSMutableArray array];
    }
    
    return _users;
}

#pragma mark - Actions
- (IBAction)infoButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowUser" sender:sender];
}

#pragma mark - UITableViewDelegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

static NSString *CellIdentifier = @"UserCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCKittyUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.nameLabel.text = [[self.users objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.balanceLabel.text = [NSString stringWithFormat:@"%@ EUR", [[self.users objectAtIndex:indexPath.row] objectForKey:@"money"]];
    cell.infoButton.tag = indexPath.row;
    
    if([KCKittyManager sharedKittyManager].selectedKittyID && [KCKittyManager sharedKittyManager] && self.selectedKittyIndex == [[KCKittyManager sharedKittyManager].selectedKittyID integerValue] && indexPath.row == [[KCKittyManager sharedKittyManager].selectedUserID integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[KCKittyManager sharedKittyManager] setSelectedKittyID:self.selectedKittyIndex andUserID:indexPath.row];
    
    [self.tableView reloadData];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowUser"]) {
        NSInteger selectedRow = [(UIButton *)sender tag];
        
        KCKittyDrinkTableViewController *dController = [segue destinationViewController];
        dController.selectedKittyIndex = self.selectedKittyIndex;
        dController.user = [self.users objectAtIndex:selectedRow];
    }
}

@end
