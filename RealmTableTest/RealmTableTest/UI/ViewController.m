//
//  ViewController.m
//  RealmTableTest
//
//  Created by Ben Clayton on 19/05/15.
//  Copyright (c) 2015 calvium. All rights reserved.
//


#import "ViewController.h"
#import "RBQFetchRequest.h"
#import "Item.h"
#import "RBQFetchedResultsController.h"
#import "FetchResultControllerDelegate.h"
#import "DetailViewController.h"
#import "SubItem.h"
#import "RLMRealm+Notifications.h"

@interface ViewController () <RBQFetchedResultsControllerDelegate>
@property(nonatomic, strong) RBQFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong) FetchResultControllerDelegate *tableViewFetchResultController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RBQFetchRequest *request = [RBQFetchRequest fetchRequestWithEntityName:[Item className]
                                                                   inRealm:[RLMRealm defaultRealm]
                                                                 predicate:nil];

    // Sort by category
    request.sortDescriptors = @[
            [RLMSortDescriptor sortDescriptorWithProperty:@"category" ascending:YES]
    ];

    self.fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:request
                                                                           sectionNameKeyPath:@"category"
                                                                                    cacheName:@"items"];

    self.tableViewFetchResultController = [[FetchResultControllerDelegate alloc] initWithTableView:self.tableView
                                                                          fetchedResultsController:self.fetchedResultsController];
    self.tableViewFetchResultController.delegate = self;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.fetchedResultsController performFetch];
}

#pragma mark - UI EVENTS

- (IBAction)editTapped:(id)sender {
    self.tableView.editing = !self.tableView.editing;
}

- (IBAction)addTapped:(id)sender {

    Item *item = [[Item alloc] init];
    item.title = [NSString stringWithFormat:@"NEW %@", @(rand() % 1000)];
    item.id = [[NSUUID UUID] UUIDString];
    item.subtitle = @"subtitle";
    item.category = @"NEW";

    SubItem *subItem = [[SubItem alloc] init];
    subItem.id = [[NSUUID UUID] UUIDString];
    subItem.count = 12;
    subItem.name = [NSString stringWithFormat:@"sub %@", item.title];
    subItem.parentId = item.id;

    [item.subitems addObject:subItem];

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObjectWithNotification:item];
    [realm commitWriteTransaction];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Detail" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteObjectAtIndexPath:indexPath];
    }
}

- (void)deleteObjectAtIndexPath:(NSIndexPath *)path {
    Item *item = [self.fetchedResultsController objectAtIndexPath:path];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjectWithNotification:item];
    [realm commitWriteTransaction];
}

#pragma mark - UITableViewDataSource

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"Detail"]) {
        if ([sender isKindOfClass:[Item class]]) {
            ((DetailViewController *) segue.destinationViewController).item = sender;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.fetchedResultsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController numberOfRowsForSectionIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.fetchedResultsController titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...
    Item *objectForCell = [self.fetchedResultsController objectInRealm:[RLMRealm defaultRealm]
                                                           atIndexPath:indexPath];

    cell.textLabel.text = objectForCell.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@ items",
                                                           objectForCell.subtitle,
                                                           @(objectForCell.subitems.count)];

    return cell;
}

// Scroll to newly-inserted rows
- (void)controller:(RBQFetchedResultsController *)controller
   didChangeObject:(RBQSafeRealmObject *)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    // TODO: This is ugly.. probably may not work in some situations. Best to wait until the didFinishChanging method apparently.
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        if (type == NSFetchedResultsChangeInsert) {
            [self.tableView scrollToRowAtIndexPath:newIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    });

}

@end