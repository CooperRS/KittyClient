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

#import "KCTextFieldCell.h"

@interface KCKittyTableViewController () <KCAddKittyViewControllerDelegate, UIAlertViewDelegate>

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
        return [self.kittys count] + 1;
    else if(section == 0)
        return 1;
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Gespeichert";
    } else if (section == 0) {
        return @"Server URL";
    }
    
    return @"";
}

static NSString *AddKittyCellIdentifier = @"AddCell";
static NSString *KittyCellIdentifier = @"KittyCell";
static NSString *URLCellIdentifier = @"URLCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
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
    } else if(indexPath.section == 0) {
        KCTextFieldCell *cell = (KCTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:URLCellIdentifier];
        cell.textField.text = [KCKittyManager sharedKittyManager].serverBaseURL;
        cell.textField.returnKeyType = UIReturnKeyDone;
        return cell;
    }
    
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        if(indexPath.row >= [self.kittys count]) {
            return UITableViewCellEditingStyleInsert;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row < [self.kittys count] && editingStyle == UITableViewCellEditingStyleDelete) {
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

#pragma mark - UITextField Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warnung" message:@"Wenn Sie die URL ändern, werden alle gespeicherten Kitties entfernt und der ausgewählte Benutzer wird zurückgesetzt. Sind Sie sich sicher, dass Sie die URL ändern möchten?" delegate:self cancelButtonTitle:@"Abbrechen" otherButtonTitles:@"Ändern", nil];
    [alert show];
    
    return YES;
}

#pragma mark - UIAlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex) {
        [[KCKittyManager sharedKittyManager] setSelectedKittyID:nil andUserID:nil];
        [[KCKittyManager sharedKittyManager] removeAllKitties];
        
        KCTextFieldCell *textFieldCell = (KCTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[KCKittyManager sharedKittyManager] setServerBaseURL:textFieldCell.textField.text];
        
        [self.tableView reloadData];
    }
}

@end
