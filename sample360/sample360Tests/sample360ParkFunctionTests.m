//
//  sample360ParkFunctionTests.m
//  sample360
//
//  Created by Chris Woodard on 8/10/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ParksLibrarian.h"
#import "ParksFunctional.h"

@interface sample360ParkFunctionTests : XCTestCase

@end

@implementation sample360ParkFunctionTests

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testGeneratedTypePredicates {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsATrail = parkHasType(@"Trail");
    ParkFilterPredicate parkIsAPark = parkHasType(@"Park");
    
    BOOL ok1 = parkIsATrail(originalParks[0]);
    BOOL ok2 = parkIsAPark(originalParks[0]);
    XCTAssertTrue(ok2, @"park should have type 'Park', not '%@'", originalParks[0][@"type"]);
    XCTAssertFalse(ok1, @"park should have type 'Park', not '%@'", originalParks[0][@"type"]);
}

-(void)testGeneratedTypePredicates2 {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsATrail = parkHasType(@"Trail");
    ParkFilterPredicate parkIsAPark = parkHasType(@"Park");
    ParkFilterPredicate parkIsConservationTract = parkHasType(@"Conservation Tract");
    
    BOOL ok1 = parkIsATrail(originalParks[10]);
    BOOL ok2 = parkIsAPark(originalParks[10]);
    BOOL ok3 = parkIsConservationTract(originalParks[10]);
    
    XCTAssertFalse(ok1, @"park should have type 'Conservation Tract', not '%@'", originalParks[10][@"type"]);
    XCTAssertFalse(ok2, @"park should have type 'Conservation Tract', not '%@'", originalParks[10][@"type"]);
    XCTAssertTrue(ok3, @"park should have type 'Conservation Tract', not '%@'", originalParks[10][@"type"]);
}

-(void)testGeneratedClassPredicatesTestOpenSpace {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsANeighborhood = parkHasClass(@"Neighborhood");
    ParkFilterPredicate parkIsOpenSpace = parkHasType(@"Open Space");
    
    BOOL ok1 = parkIsANeighborhood(originalParks[4]);
    BOOL ok2 = parkIsOpenSpace(originalParks[4]);
    XCTAssertTrue(ok2, @"park should have class 'Open Space', not '%@'", originalParks[4][@"class"]);
    XCTAssertFalse(ok1, @"park should have type 'Neighborhood', not '%@'", originalParks[4][@"class"]);
}

-(void)testGeneratedClassPredicatesTestRegional {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsRecCenter = parkHasClass(@"Recreation Center");
    ParkFilterPredicate parkIsOpenSpace = parkHasType(@"Open Space");
    
    BOOL ok1 = parkIsRecCenter(originalParks[5]);
    BOOL ok2 = parkIsOpenSpace(originalParks[5]);
    XCTAssertTrue(ok1, @"park should have class 'Recreation Center', not '%@'", originalParks[5][@"class"]);
    XCTAssertFalse(ok2, @"park should have type 'Neighborhood', not '%@'", originalParks[5][@"class"]);
}

-(void)testGeneratedClassPredicatesTestRegionalParks {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsNeighborhoodPark = parkHasClassAndType(@"Neighborhood", @"Park");
    
    BOOL ok = parkIsNeighborhoodPark(originalParks[0]);
    XCTAssertTrue(ok, @"park should have be 'Neighborhood' and 'Park', not '%@' and '%@'", originalParks[0][@"class"], originalParks[0][@"type"]);
}

-(void)testGeneratedClassPredicatesTestRecreationCenterGrounds {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkIsNeighborhoodPark = parkHasClassAndType(@"Recreation Center", @"Grounds");
    
    BOOL ok = parkIsNeighborhoodPark(originalParks[5]);
    XCTAssertTrue(ok, @"park should have be 'RecreationCenter' and 'Grounds', not '%@' and '%@'", originalParks[5][@"class"], originalParks[5][@"type"]);
}

-(void)testGeneratedClassPredicatesTestBiking {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkHasBiking = parkHasTag(@"Biking");
    
    BOOL ok = parkHasBiking(originalParks[4]);
    XCTAssertTrue(ok, @"park should have Biking");
}

-(void)testGeneratedClassPredicatesTestWater {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    
    NSDictionary *results = [pl parks];
    NSArray *originalParks = results[@"data"];
    
    ParkFilterPredicate parkHasWater = parkHasTag(@"Water");
    
    BOOL ok = parkHasWater(originalParks[6]);
    XCTAssertTrue(ok, @"park should have Water");
}

@end
