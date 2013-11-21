//
//  KittyTableViewController.m
//  KittyClient
//
//  Created by Roland Moers on 26.09.13.
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
        return NSLocalizedString(@"Saved", nil);
    } else if (section == 0) {
        return NSLocalizedString(@"Server URL", nil);
    }
    
    return @"";
}

static NSString *AddKittyCellIdentifier = @"AddCell";
static NSString *KittyCellIdentifier = @"KittyCell";
static NSString *URLCellIdentifier = @"URLCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Path: %i, %i", indexPath.section, indexPath.row);
    
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"If you change the server URL, all saved kitties will be deleted and the selected kitty and user will be resetted. Di you want to change the server URL?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Change", nil), nil];
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
