//
//  NSArray+Functional.h
//  FunctionalProgramming
//
//  Created by james c Woodard on 1/10/15.
//  Copyright (c) 2015 TBCocoaheads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

-(NSArray *)map:(id(^)(id))mapBlock;
-(NSArray *)filter:(BOOL(^)(id))filterBlock;
-(id)reduce:(id)initialValue reductor:(id(^)(id, id))reductorBlock;
-(id)reduce2:(id)initialValue reductor:(id(^)(id, id, BOOL, BOOL))reductorBlock;

@end

