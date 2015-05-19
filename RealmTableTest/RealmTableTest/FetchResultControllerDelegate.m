#import "FetchResultControllerDelegate.h"
#import "RBQFetchedResultsController.h"

@implementation FetchResultControllerDelegate {

}
- (instancetype)initWithTableView:(UITableView *)tableView
         fetchedResultsController:(RBQFetchedResultsController *)fetchedResultsController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.fetchedResultsController = fetchedResultsController;
        self.fetchedResultsController.delegate = self;
    }

    return self;
}

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller {
    NSLog(@"Beginning updates");
    [self.tableView beginUpdates];
}

- (void)controller:(RBQFetchedResultsController *)controller
   didChangeObject:(RBQSafeRealmObject *)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert: {
            NSLog(@"Inserting at path %@", newIndexPath);
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            NSLog(@"Deleting at path %ld", (long) indexPath.row);
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Updating at path %@", indexPath);
            if ([[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            break;

        case NSFetchedResultsChangeMove:
            NSLog(@"Moving from path %@ to %@", indexPath, newIndexPath);
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }

    // Pass on to self.delegate
    if ([self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate controller:controller
                  didChangeObject:anObject
                      atIndexPath:indexPath
                    forChangeType:type
                     newIndexPath:newIndexPath];
    }
}

- (void)controller:(RBQFetchedResultsController *)controller
  didChangeSection:(RBQFetchedResultsSectionInfo *)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = self.tableView;

    if (type == NSFetchedResultsChangeInsert) {
        NSLog(@"Inserting section at %lu", (unsigned long) sectionIndex);
        NSIndexSet *insertedSection = [NSIndexSet indexSetWithIndex:sectionIndex];

        [tableView insertSections:insertedSection withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        NSLog(@"Deleting section at %lu", (unsigned long) sectionIndex);
        NSIndexSet *deletedSection = [NSIndexSet indexSetWithIndex:sectionIndex];

        [tableView deleteSections:deletedSection withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller {
    NSLog(@"Ending updates");
    NSLog(@"Fetched %ld Items After Change", (unsigned long) self.fetchedResultsController.fetchedObjects.count);
    @try {
        [self.tableView endUpdates];
    }
    @catch (NSException *ex) {
        NSLog(@"RBQFecthResultsTVC caught exception updating table view: %@. Falling back to reload.", ex);

        [self.fetchedResultsController reset];

        [self.tableView reloadData];
    }
}

@end