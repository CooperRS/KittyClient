//
//  KittyTableViewController.m
//  KittyClient
//
//  Created by Simon Jakubowski on 26.09.13.
//  Copyright (c) 2013 Simon Jakubowski. All rights reserved.
//

#import "KittyTableViewController.h"
#import "AddKittyViewController.h"
#import "UserTableViewController.h"

@interface KittyTableViewController () <AddKittyViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* kittys;

@end

@implementation KittyTableViewController

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
    self.kittys = [NSMutableArray array];
    
    [self.kittys addObjectsFromArray:[self loadKittysFromXML]];

    [super viewDidLoad];

}

- (NSArray*) loadKittysFromXML {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"Kittys.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Kittys" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization
                                propertyListFromData:plistXML
                                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                format:&format
                                errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }

    return temp;
}

- (void) saveKittysToXMLwithArray: (NSArray*) kittys {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Kittys.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:kittys
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.kittys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *aKitty = [self.kittys objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [aKitty objectForKey:@"name"], [aKitty objectForKey:@"kittyId"]];
    cell.detailTextLabel.text = [aKitty objectForKey:@"createdBy"];
    
    return cell;
}

#pragma mark - Delegate methods

- (void)addValidKitty:(NSDictionary*) aKitty {
    [self.kittys addObject:aKitty];
    [self.tableView reloadData];
    [self saveKittysToXMLwithArray:self.kittys];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"addKitty"]) {
        [[segue destinationViewController] setDelegate:self];
    }
    else if ([[segue identifier] isEqualToString:@"selectKitty"]) {
        UserTableViewController *dController = [segue destinationViewController];
        NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
        dController.aKitty = [self.kittys objectAtIndex:selectedRow.row];
    }
}


@end
