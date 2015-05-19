//
//  AppDelegate.m
//  RealmTableTest
//
//  Created by Ben Clayton on 19/05/15.
//  Copyright (c) 2015 calvium. All rights reserved.
//


#import "AppDelegate.h"
#import "Item.h"
#import "RLMResults.h"
#import "RLMRealm.h"
#import "RLMArray.h"
#import "SubItem.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSArray *categories = @[@"fish", @"cheese", @"crisps", @"meat", @"vegetables", @"chocolate", @"cake"];

    int id = 0;

    // gen fake data if empty (on main thread!)
    RLMResults *results = [Item allObjects];
    if (results.count == 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSLog(@"Realm at %@", realm.path);

        [realm beginWriteTransaction];
        for (int i = 0; i < 100; i++) {
            Item *item = [Item new];
            item.title = [NSString stringWithFormat:@"Item %@", @(i)];
            item.subtitle = [NSString stringWithFormat:@"Subtitle %@", @(i)];
            item.category = categories[rand() % categories.count];
            item.id = [NSString stringWithFormat:@"%@", @(id++)];

            int subCount = rand() % 10;
            for (int j = 0; j < subCount; j++) {
                SubItem *subItem = [SubItem new];
                subItem.name = [NSString stringWithFormat:@"%@ subitem %@", item.title, @(j)];
                subItem.count = rand() % 100;
                subItem.id = [NSString stringWithFormat:@"%@", @(id++)];
                subItem.parentId = item.id;
                [item.subitems addObject:subItem];
            }

            [realm addObject:item];

        }
        [realm commitWriteTransaction];
        NSLog(@"Written items!");
    }

    return YES;
}

@end