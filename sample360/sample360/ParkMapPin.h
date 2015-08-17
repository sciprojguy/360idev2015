//
//  ParkMapPin.h
//  sample360
//
//  Created by Chris Woodard on 8/12/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkMapPin : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end
