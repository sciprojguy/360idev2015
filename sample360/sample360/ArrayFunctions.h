//
//  ArrayFunctions.h
//  FunctionalProgramming
//
//  Created by Chris Woodard on 1/18/15.
//  Copyright (c) 2015 TBCocoaheads. All rights reserved.
//

#ifndef FunctionalProgramming_ArrayFunctions_h
#define FunctionalProgramming_ArrayFunctions_h

// functional
NSArray *mapArray( NSArray *inArray, id (^mapBlock)(id));
NSArray *filterArray( NSArray *inArray, BOOL (^filterBlock)(id));
id reduceArray( NSArray *inArray, id initialValue, id (^reductorBlock)(id, id));
id reduceArray2( NSArray *inArray, id initialValue, id (^reductorBlock)(id, id, BOOL, BOOL));

#endif
