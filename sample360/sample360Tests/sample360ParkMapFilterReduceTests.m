//
//  sample360ParkMapFilterReduceTests.m
//  sample360
//
//  Created by Chris Woodard on 8/10/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

#import "ArrayFunctions.h"
#import "NSArray+Functional.h"

#import "ParksLibrarian.h"
#import "ParksFunctional.h"

@interface sample360ParkMapFilterReduceTests : XCTestCase

@end

@implementation sample360ParkMapFilterReduceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// test with inline filter predicates

- (void)testParkFilteringForTrailsWithFunction {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    NSArray *filteredParks = filterArray(originalParks, ^BOOL(NSDictionary *park) {
        return [@"Trail" isEqualToString:park[@"type"]];
    });
    
    XCTAssertEqual(10, filteredParks.count, @"Should be 10 trails");
}

- (void)testParkFilteringForTrails {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    NSArray *filteredParks = [originalParks filter:^BOOL(NSDictionary *park) {
        return [@"Trail" isEqualToString:park[@"type"]];
    }];
    
    XCTAssertEqual(10, filteredParks.count, @"Should be 10 trails");
}

- (void)testParkFilteringForTrailsWithGeneratedPredicate {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsATrail = parkHasType(@"Trail");
    NSArray *filteredParks = [originalParks filter:parkIsATrail];
    
    XCTAssertEqual(10, filteredParks.count, @"Should be 10 trails");
}

-(void)testParkFilteringForGolf {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    NSArray *filteredParks = [originalParks filter:^BOOL(NSDictionary *park) {
        return [@"Golf" isEqualToString:park[@"type"]];
    }];
    
    XCTAssertEqual(7, filteredParks.count, @"Should be 7 golf courses");
}

// test for reduce blocks

-(void)testReduceToCollectTypes {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    NSArray *initialTypesArray = @[];
    NSArray *tagsArray = [originalParks reduce:initialTypesArray reductor:^NSArray *(NSArray *accum, NSDictionary *element) {
        NSString *parkType = element[@"type"];
        NSSet *setOfTypes = [NSSet setWithArray:accum];
        setOfTypes = [setOfTypes setByAddingObjectsFromArray:@[parkType]];
        return [setOfTypes allObjects];
    }];
 
    XCTAssertEqual(7, tagsArray.count, @"Should be 7 tags");
}

-(void)testReduceToCollectTags {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    NSArray *initialTagsArray = @[];
    NSSet *tagsArray = [originalParks reduce:initialTagsArray reductor:^NSArray *(NSArray *accum, NSDictionary *element) {
        NSArray *parkTags = element[@"tags"];
        NSSet *setOfTags = [NSSet setWithArray:accum];
        setOfTags = [setOfTags setByAddingObjectsFromArray:parkTags];
        return [setOfTags allObjects];
    }];
 
    XCTAssertEqual(7, tagsArray.count, @"Should be 7 tags");
}

-(void)testReduceForBoxAndCenter {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];

    NSDictionary *tuple = @{
        @"N":@(0),
        @"CenterLat":@(0.0),
        @"CenterLon":@(0.0),
        @"MinLat":@(9999.99),
        @"MinLon":@(9999.99),
        @"MaxLat":@(-9999.99),
        @"MaxLon":@(-9999.99)
    };
    
    NSDictionary *statsTuple = [originalParks reduce2:tuple reductor:^NSDictionary *(NSDictionary *accum, NSDictionary *element, BOOL firstPark, BOOL lastPark) {
    
        NSDictionary *returnTuple = nil;
        
        if(firstPark) {
            returnTuple = @{
                @"N":@(1),
                @"CenterLat":element[@"lat"],
                @"CenterLon":element[@"lon"],
                @"MinLat":element[@"lat"],
                @"MinLon":element[@"lon"],
                @"MaxLat":element[@"lat"],
                @"MaxLon":element[@"lon"]
            };
        }
        else {
        
            long N = [accum[@"N"] longValue];
            
            double minLat = [accum[@"MinLat"] doubleValue];
            double minLon = [accum[@"MinLon"] doubleValue];
            double maxLat = [accum[@"MaxLat"] doubleValue];
            double maxLon = [accum[@"MaxLon"] doubleValue];
            double centerLat = [accum[@"CenterLat"] doubleValue];
            double centerLon = [accum[@"CenterLon"] doubleValue];
            
            double latitude = [element[@"lat"] doubleValue];
            double longitude = [element[@"lon"] doubleValue];
            
            minLat = MIN(latitude, minLat);
            maxLat = MAX(latitude, maxLat);
            minLon = MIN(longitude, minLon);
            maxLon = MAX(longitude, maxLon);
            
            centerLat += latitude;
            centerLon += longitude;
            
            N++;
            
            if(lastPark) {
                // compute average lat/lon for centroid
                centerLat /= (double)N;
                centerLon /= (double)N;
            }
            
            returnTuple = @{
                @"N":@(N),
                @"CenterLat":@(centerLat),
                @"CenterLon":@(centerLon),
                @"MinLat":@(minLat),
                @"MinLon":@(minLon),
                @"MaxLat":@(maxLat),
                @"MaxLon":@(maxLon)
            };
        }
        
        return returnTuple;
    }];

    XCTAssertEqualWithAccuracy([statsTuple[@"CenterLat"] doubleValue], 39.7114, 0.0001, @"CenterLat is wrong" );
    XCTAssertEqualWithAccuracy([statsTuple[@"CenterLon"] doubleValue], -105.003, 0.001, @"CenterLon is wrong" );
}

// test filtering with a generated predicate

-(void)testParkFilteringForGolfWithGeneratedPredicate {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsGolfCourse = parkHasType(@"Golf");
    
    NSArray *filteredParks = [originalParks filter:parkIsGolfCourse];
    
    XCTAssertEqual(7, filteredParks.count, @"Should be 7 golf courses");
}

// test/demo simple reduce predicates

-(void)testReduceArrayFunctionCommaSeparatedStrings {
    NSArray *myInArray = @[ @"One", @"Two", @"Three", @"Four" ];
    NSString *concatenatedString = reduceArray2(myInArray, @"", ^(NSString *accumStr, NSString *elStr, BOOL firstElement, BOOL lastElement) {
        NSString *str = nil;
        if(YES == firstElement) {
            str = elStr;
        }
        else {
            str = [NSString stringWithFormat:@"%@, %@", accumStr, elStr];
        }
        return str;
    });
    
    XCTAssertTrue( [@"One, Two, Three, Four" isEqualToString:concatenatedString], @"string not done right");
}

-(void)testReduceArrayFunctionCommaSeparatedStringsWithAnd {
    NSArray *myInArray = @[ @"One", @"Two", @"Three", @"Four" ];
    NSString *concatenatedString = reduceArray2(myInArray, @"", ^(NSString *accumStr, NSString *elStr, BOOL firstElement, BOOL lastElement) {
        NSString *str = nil;
        if(YES == firstElement) {
            str = elStr;
        }
        else
        if(YES == lastElement) {
            str = [NSString stringWithFormat:@"%@ and %@", accumStr, elStr];
        }
        else
        if(NO == lastElement) {
            str = [NSString stringWithFormat:@"%@, %@", accumStr, elStr];
        }
        return str;
    });
    
    XCTAssertTrue( [@"One, Two, Three and Four" isEqualToString:concatenatedString], @"string not done right");
}

-(void)testReduceArrayFunctionSum {
    NSArray *myInArray = @[ @(12.5), @(15.6), @(50.0) ];
    NSNumber *sum = reduceArray(myInArray, @(0), ^(NSNumber *accum, NSNumber *element) {
        NSNumber *number;
        number = @( [element doubleValue] + [accum doubleValue] );
        return number;
    });
    
    XCTAssertEqualWithAccuracy(78.1, [sum doubleValue], 0.1, @"Wrong sum");
}

-(void)testReduceArrayFunctionAvg {
    NSArray *myInArray = @[ @(12.5), @(15.6), @(50.0) ];
    NSDictionary *tuple = reduceArray2(myInArray, @(0), ^(NSDictionary *accum, NSNumber *element, BOOL firstNum, BOOL lastNum) {
        NSDictionary *tuple;
        if(firstNum) {
            tuple = @{@"N":@(1), @"Sum":element};
        }
        else
        {
            tuple = @{@"N":@([accum[@"N"] intValue]+1), @"Sum":@([accum[@"Sum"] doubleValue] + [element doubleValue])};
            if(lastNum) {
                tuple = @{@"N":tuple[@"N"], @"Avg":@([tuple[@"Sum"] doubleValue]/[tuple[@"N"] integerValue])};
            }
        }
        return tuple;
    });
    
    XCTAssertEqual( 3, [tuple[@"N"] integerValue], @"should have been 3 numbers");
    XCTAssertEqualWithAccuracy(26.0, [tuple[@"Avg"] doubleValue], 0.1, @"wrong average");
}

@end
