//
//  ParksFunctional.h
//  sample360
//
//  Created by Chris Woodard on 8/11/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef sample360_ParksFunctional_h
#define sample360_ParksFunctional_h

typedef BOOL (^ParkFilterPredicate)(NSDictionary *);

ParkFilterPredicate parkHasClass(NSString *parkClass);
ParkFilterPredicate parkHasType(NSString *parkType);
ParkFilterPredicate parkHasClassAndType(NSString *parkClass, NSString *parkType);
ParkFilterPredicate parkHasTag(NSString *parkAmenity);

#endif
