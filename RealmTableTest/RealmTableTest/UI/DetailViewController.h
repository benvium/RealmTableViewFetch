#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FetchResultControllerDelegate;
@class Item;

@interface DetailViewController : UITableViewController
@property(nonatomic, strong) Item *item;
@end