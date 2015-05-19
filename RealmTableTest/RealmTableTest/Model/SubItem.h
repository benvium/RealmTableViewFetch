#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RLMObject.h"

@class Item;

@interface SubItem : RLMObject
@property NSString* id;
@property NSString *name;
@property double count;
@property NSString* parentId;
@end
RLM_ARRAY_TYPE(SubItem) // can have arrays of these