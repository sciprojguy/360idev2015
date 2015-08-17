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

@end
