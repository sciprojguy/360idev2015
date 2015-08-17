//
//  ParksFunctional.m
//  sample360
//
//  Created by Chris Woodard on 8/11/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ParksFunctional.h"

ParkFilterPredicate parkHasClass(NSString *parkClass) {
    return ^BOOL(NSDictionary *parkInfo) {
        return [parkClass isEqualToString:parkInfo[@"class"]];
    };
}

ParkFilterPredicate parkHasType(NSString *parkType) {
    return ^BOOL(NSDictionary *parkInfo) {
        return [parkType isEqualToString:parkInfo[@"type"]];
    };
}

ParkFilterPredicate parkHasClassAndType(NSString *parkClass, NSString *parkType) {
    return ^BOOL(NSDictionary *parkInfo) {
        return [parkType isEqualToString:parkInfo[@"type"]] && [parkClass isEqualToString:parkInfo[@"class"]];
    };
}

ParkFilterPredicate parkHasTag(NSString *parkTag) {
    return ^BOOL(NSDictionary *parkInfo) {
        BOOL hasTag = NO;
        NSArray *tags = parkInfo[@"tags"];
        for( NSString *tag in tags ) {
            if([tag isEqualToString:parkTag]) {
                hasTag = YES;
                break;
            }
        }
        return hasTag;
    };
}
