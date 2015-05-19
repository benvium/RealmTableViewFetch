#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RBQFetchedResultsController.h"

@class RBQFetchedResultsController;

/**
* Implements the boilerplate required to update a tableview based on the fetched results controller
*/
@interface FetchResultControllerDelegate : NSObject <RBQFetchedResultsControllerDelegate>
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) RBQFetchedResultsController *fetchedResultsController;

// Used to pass on calls if required
@property(nonatomic, weak) id <RBQFetchedResultsControllerDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView
         fetchedResultsController:(RBQFetchedResultsController *)fetchedResultsController;

@end