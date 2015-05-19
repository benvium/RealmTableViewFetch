#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RLMObject.h"

@protocol SubItem;
@class RLMArray;

@interface Item : RLMObject
@property NSString* id;
@property NSString* title;
@property NSString* subtitle;
@property NSString* category;
@property RLMArray<SubItem>* subitems;
@end