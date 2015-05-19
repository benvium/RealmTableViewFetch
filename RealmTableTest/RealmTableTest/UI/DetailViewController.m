#import <Realm/realm/RLMRealm.h>
#import <RBQFetchedResultsController/RBQFetchRequest.h>
#import <RBQFetchedResultsController/RBQFetchedResultsController.h>
#import <RBQFetchedResultsController/RLMRealm+Notifications.h>
#import "FetchResultControllerDelegate.h"
#import "Item.h"
#import "DetailViewController.h"
#import "SubItem.h"
#import "FetchResultControllerDelegate.h"
#import "RBQRealmNotificationManager.h"

@interface DetailViewController ()
@property(nonatomic, strong) RBQFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong) FetchResultControllerDelegate *tableViewFetchResultController;
@end

@implementation DetailViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.item.title;

    RBQFetchRequest *request = [RBQFetchRequest fetchRequestWithEntityName:[SubItem className]
                                                                   inRealm:[RLMRealm defaultRealm]
                                                                 predicate:[NSPredicate predicateWithFormat:@"parentId == %@",
                                                                                                            self.item.id]];

    // Sort by count (descending)
    request.sortDescriptors = @[
            [RLMSortDescriptor sortDescriptorWithProperty:@"count" ascending:NO]
    ];

    self.fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:request
                                                                           sectionNameKeyPath:nil
                                                                                    cacheName:nil];

    self.tableViewFetchResultController = [[FetchResultControllerDelegate alloc] initWithTableView:self.tableView
                                                                          fetchedResultsController:self.fetchedResultsController];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.fetchedResultsController performFetch];
}

- (IBAction)addTapped:(id)sender {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    SubItem *subItem = [SubItem new];
    subItem.id = [[NSUUID UUID] UUIDString];
    subItem.parentId = self.item.id;
    subItem.name = [NSString stringWithFormat:@"NEW %@", @(rand() % 1000)];
    subItem.count = rand() % 1000;
    [self.item.subitems addObject:subItem]; // add to list AND...
    [realm addObjectWithNotification:subItem]; // add to store. This is because I can't get the inverse relationship to work.
    [[RBQRealmChangeLogger defaultLogger] didChangeObject:self.item];
    [realm commitWriteTransaction];

}

#pragma mark - UITableViewDataSource

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
    SubItem *objectForCell = [self.fetchedResultsController objectInRealm:[RLMRealm defaultRealm]
                                                              atIndexPath:indexPath];

    cell.textLabel.text = objectForCell.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(objectForCell.count)];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteObjectAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SubItem *subItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    subItem.count += 50;
    [[RBQRealmChangeLogger defaultLogger] didChangeObject:subItem];
    [realm commitWriteTransaction];
}

- (void)deleteObjectAtIndexPath:(NSIndexPath *)path {
    Item *item = [self.fetchedResultsController objectAtIndexPath:path];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjectWithNotification:item];
    [[RBQRealmChangeLogger defaultLogger] didChangeObject:self.item]; // Note that I didn't have to add it to the list!
    [realm commitWriteTransaction];
}

@end