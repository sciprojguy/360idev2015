//
//  ParksLibrarian.m
//  sample360
//
//  Created by Chris Woodard on 8/8/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import "ParksLibrarian.h"

@interface ParksLibrarian ()
@property (nonatomic, strong) NSString *cachedDbPath;
@property (nonatomic, strong) NSString *bundleDbPath;
@end

@implementation ParksLibrarian

-(NSString *)jsonPath {
    if(nil == _bundleDbPath) {
        self.bundleDbPath = [[NSBundle mainBundle] pathForResource:@"parks" ofType:@"json"];
    }
    return _bundleDbPath;
}

-(NSDictionary *)parks {
    NSError *err = nil;
    NSString *parksJsonPath = [self jsonPath];
    NSData *parksJSON = [NSData dataWithContentsOfFile:parksJsonPath];
    NSArray *parksArray = [NSJSONSerialization JSONObjectWithData:parksJSON options:NSJSONReadingMutableContainers error:&err];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    if(nil == err) {
        results[@"data"] = parksArray;
    }
    else {
        results[@"error"] = err;
    }
    
    return results;
}

@end
