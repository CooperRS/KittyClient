//
//  KittyTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 26.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KCKittyTableViewController.h"

#import "KCAddKittyViewController.h"
#import "KCKittyUserTableViewController.h"

#import "KCKittyManager.h"

@interface KCKittyTableViewController () <KCAddKittyViewControllerDelegate>

@property (nonatomic, strong) NSArray *kittys;

@end

@implementation KCKittyTableViewController

#pragma mark - Properties
- (NSArray *)kittys {
    return [KCKittyManager sharedKittyManager].kitties;
}

#pragma mark - Actions
- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableVide Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.kittys count] + 1;
}

static NSString *AddKittyCellIdentifier = @"AddCell";
static NSString *KittyCellIdentifier = @"KittyCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= [self.kittys count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddKittyCellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KittyCellIdentifier forIndexPath:indexPath];
        NSDictionary *aKitty = [self.kittys objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [aKitty objectForKey:@"name"], [aKitty objectForKey:@"kittyId"]];
        cell.detailTextLabel.text = [aKitty objectForKey:@"createdBy"];
        
        return cell;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= [self.kittys count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [self.kittys count] && editingStyle == UITableViewCellEditingStyleDelete) {
        [[KCKittyManager sharedKittyManager] removeKittyAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - KCAddKittyViewController
- (void)addKittyVCDidFinish:(KCAddKittyViewController *)addKittyVC {
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addKittyVCDidCancel:(KCAddKittyViewController *)addKittyVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddKitty"]) {
        [(KCAddKittyViewController *)[(UINavigationController *)[segue destinationViewController] topViewController] setDelegate:self];
    } else if ([[segue identifier] isEqualToString:@"ShowKitty"]) {
        NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
        
        KCKittyUserTableViewController *dController = [segue destinationViewController];
        dController.selectedKittyIndex = selectedRow.row;
    }
}


@end
