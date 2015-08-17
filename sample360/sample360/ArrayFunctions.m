//
//  ArrayFunctions.m
//  FunctionalProgramming
//
//  Created by Chris Woodard on 1/18/15.
//  Copyright (c) 2015 TBCocoaheads. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray *mapArray( NSArray *inArray, id (^mapBlock)(id)) {
    NSMutableArray *mappedArray = [NSMutableArray array];
    for( id inObject in inArray ) {
        id outObject = mapBlock(inObject);
        [mappedArray addObject:outObject];
    }
    return [NSArray arrayWithArray:mappedArray];
}

NSArray *filterArray( NSArray *inArray, BOOL (^filterBlock)(id)) {
    NSMutableArray *filteredArray = [NSMutableArray array];
    for( id inObject in inArray ) {
        if(filterBlock(inObject)) {
            id outObject = [inObject copy];
            [filteredArray addObject:outObject];
        }
    }
    return filteredArray;
}

id reduceArray( NSArray *inArray, id initialValue, id (^reductorBlock)(id, id)) {
    id accumulatedValue = [initialValue copy];
    for( id element in inArray ) {
        accumulatedValue = reductorBlock( accumulatedValue, element );
    }
    return accumulatedValue;
}

// modified version of reduceArray() - the reductor block in this one gets
// not only the accumulator and the value, but also two flags to indicate
// when the value is the first or the last object in the array/sequence

id reduceArray2( NSArray *inArray, id initialValue, id (^reductorBlock)(id, id, BOOL, BOOL)) {
    id accumulatedValue = [initialValue copy];
    id firstObject = inArray.firstObject;
    id lastObject = inArray.lastObject;
    for( id element in inArray ) {
        accumulatedValue = reductorBlock( accumulatedValue, element, element == firstObject, element == lastObject );
    }
    return accumulatedValue;
}
