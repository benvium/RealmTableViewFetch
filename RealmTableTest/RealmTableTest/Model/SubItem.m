#import "SubItem.h"
#import "Item.h"

@implementation SubItem {

}

+ (NSString *)primaryKey {
    return @"id";
}

//- (NSString *)parentId {
//    NSArray *array = [self linkingObjectsOfClass:[Item className]
//                                     forProperty:@"subitems"];
//
//    if (!array.count) {
//        return nil;
//    }
//    Item *parent = array.firstObject;
//    return parent.id;
//}

- (NSArray *)parents {
    return [self linkingObjectsOfClass:[Item className] forProperty:@"subitems"];
}

@end