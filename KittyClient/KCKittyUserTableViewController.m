//
//  UserTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 27.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyUserTableViewController.h"
#import "MBProgressHUD.h"

#import "KCKittyDrinkTableViewController.h"
#import "KCKittyUserCell.h"

#import "KCKittyManager.h"
#import "AFHTTPRequestOperation.h"

@interface KCKittyUserTableViewController ()

@property (nonatomic, strong) NSDictionary *kitty;
@property (nonatomic, strong) NSMutableArray *users;

@end

@implementation KCKittyUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.kitty[@"name"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Laden..";
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:[KCKittyManager sharedKittyManager].serverURL, @"users", [self.kitty objectForKey:@"kittyId"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *newUsers = [NSMutableArray array];
        for (NSDictionary *aUser in responseObject) {
            [newUsers addObject:aUser];
        }
        self.users = newUsers;
        
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Beim Laden der Benutzer ist ein Fehler passiert. Bitte erneut versuchen." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (IBAction)exportButtonTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"kitty://%@", self.kitty[@"kittyId"]]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Benutzer";
    }
    
    return @"";
}

static NSString *CellIdentifier = @"UserCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KCKittyUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *userDict = [self.users objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [userDict objectForKey:@"name"];
    cell.balanceLabel.text = [NSString stringWithFormat:@"%.2f €", [[userDict objectForKey:@"money"] doubleValue]];
    cell.infoButton.tag = indexPath.row;
    
    if([[self.kitty objectForKey:@"kittyId"] isEqualToString:[KCKittyManager sharedKittyManager].selectedKittyID] && [[userDict objectForKey:@"userId"] isEqualToNumber:[KCKittyManager sharedKittyManager].selectedUserID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userDict = [self.users objectAtIndex:indexPath.row];
    [[KCKittyManager sharedKittyManager] setSelectedKittyID:[self.kitty objectForKey:@"kittyId"] andUserID:[userDict objectForKey:@"userId"]];
    
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
