//
//  sample360Tests.m
//  sample360Tests
//
//  Created by Chris Woodard on 8/2/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ParksLibrarian.h"

@interface sample360LibrarianTests : XCTestCase

@end

@implementation sample360LibrarianTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testCreateParksLibrarian {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
}

-(void)testCreateParksLibrarianCheckArrayForNil {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    XCTAssertNotNil(results, @"unable to allocate results");
    XCTAssertNotNil(results[@"data"], @"no data, dude.");
}

-(void)testCreateParksLibrarianCheckArrayForCount {
    ParksLibrarian *pl = [[ParksLibrarian alloc] init];
    XCTAssertNotNil(pl, @"unable to allocate ParksLibrarian");
    
    NSDictionary *results = [pl parks];
    XCTAssertEqual(323, [results[@"data"] count], @"should be 323, not %d", (int)[results[@"data"] count]);
}

@end
