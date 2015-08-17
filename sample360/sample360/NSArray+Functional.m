//
//  NSArray+Functional.m
//  FunctionalProgramming
//
//  Created by james c Woodard on 1/10/15.
//  Copyright (c) 2015 TBCocoaheads. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

-(NSArray *)map:(id(^)(id))mapBlock {
    NSMutableArray *mappedArray = [NSMutableArray array];
    for( id object in self ) {
        id newObject = mapBlock(object);
        [mappedArray addObject:newObject];
    }
    return mappedArray;
}

-(NSArray *)filter:(BOOL(^)(id))filterBlock {
    NSMutableArray *filteredArray = [NSMutableArray array];
    for( id inObject in self ) {
        if(filterBlock(inObject)) {
            id outObject = [inObject copy];
            [filteredArray addObject:outObject];
        }
    }
    return filteredArray;
}

-(id)reduce:(id)initialValue reductor:(id(^)(id, id))reductorBlock {
    id accumulatedValue = [initialValue copy];
    for( id element in self ) {
        accumulatedValue = reductorBlock( accumulatedValue, element);
    }
    return accumulatedValue;
}

-(id)reduce2:(id)initialValue reductor:(id(^)(id, id, BOOL, BOOL))reductorBlock {
    id accumulatedValue = [initialValue copy];
    id firstObject = self.firstObject;
    id lastObject = self.lastObject;
    for( id element in self ) {
        accumulatedValue = reductorBlock( accumulatedValue, element, element == firstObject, element == lastObject );
    }
    return accumulatedValue;
}

@end
