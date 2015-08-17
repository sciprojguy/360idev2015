//
//  ViewController.m
//  sample360
//
//  Created by Chris Woodard on 8/2/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import "ParksViewController.h"

#import "ParksLibrarian.h"

#import "ArrayFunctions.h"
#import "NSArray+Functional.h"

#import "ParkMapPin.h"

@interface ParksViewController ()
@property (nonatomic, strong) ParksLibrarian *pLib;

@property (nonatomic, strong) NSArray *originalParks;
@property (nonatomic, strong) NSArray *visibleParks;
@property (nonatomic, strong) NSArray *visiblePins;
@property (nonatomic, strong) NSArray *parkTags;

@property (nonatomic, assign) NSInteger activeView;
@end

UIImage *imageForParkType(NSString *parkType) {
    
    UIImage *img = [UIImage imageNamed:@"icon_park_big.png"];
    
    if([@"Conservation Tract" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"lc_icon_nature_150px.png"];
    }
    else
    if([@"Future" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"lc_icon_nature_150px.png"];
    }
    else
    if([@"Golf" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"icon-golf-large.png"];
    }
    else
    if([@"Grounds" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"icon_park_big.png"];
    }
    else
    if([@"Open Space" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"openSpace.png"];
    }
    else
    if([@"Park" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"icon_park_big.png"];
    }
    else
    if([@"Trail" isEqualToString:parkType]) {
        img = [UIImage imageNamed:@"hiking-icon.jpg"];
    }

    return img;
}

MKAnnotationView *mapPinForPark(ParkMapPin *pinInfo) {

    MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:pinInfo reuseIdentifier:@"MapPin"];
    pinView.image = imageForParkType(pinInfo.type);
    pinView.canShowCallout = YES;
    return pinView;
}

ParkMapPin *annotationForPark(NSDictionary *parkInfo) {

    ParkMapPin *pin = [[ParkMapPin alloc] init];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([parkInfo[@"lat"] doubleValue], [parkInfo[@"lon"] doubleValue]);
    pin.coordinate = coordinate;
    pin.title = parkInfo[@"name"];
    pin.subtitle = parkInfo[@"class"];
    pin.type = parkInfo[@"type"];
    return pin;
}

@implementation ParksViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    // grab the librarian reference
    self.pLib = [[ParksLibrarian alloc] init];
    
    // grab the list of parks
    NSDictionary *results = [_pLib parks];
    if(nil == results[@"error"]) {
        self.originalParks = results[@"data"];
        self.visibleParks = results[@"data"];
    }
    else {
        self.originalParks = [NSArray array];
        self.visibleParks = [NSArray array];
        self.visiblePins = [NSArray array];
    }
    
    self.parkTags = [self tagsToDisplay];
    
    // set up the map
    [self setUpMap];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(MKCoordinateRegion)mapAreaContainingParks:(NSArray *)parks {

    NSDictionary *tuple = @{
        @"N":@(0),
        @"CenterLat":@(0.0),
        @"CenterLon":@(0.0),
        @"MinLat":@(9999.99),
        @"MinLon":@(9999.99),
        @"MaxLat":@(-9999.99),
        @"MaxLon":@(-9999.99)
    };
    
    NSDictionary *statsTuple = [parks reduce2:tuple reductor:^NSDictionary *(NSDictionary *accum, NSDictionary *element, BOOL firstPark, BOOL lastPark) {
    
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

    CLLocationCoordinate2D mapCenter;
    MKCoordinateSpan mapSpan;
    
    mapCenter.latitude = [statsTuple[@"CenterLat"] doubleValue];
    mapCenter.longitude = [statsTuple[@"CenterLon"] doubleValue];
    
    double deltaLatitude = [statsTuple[@"MaxLat"] doubleValue] - [statsTuple[@"MinLat"] doubleValue];
    double deltaLongitude = [statsTuple[@"MaxLon"] doubleValue] - [statsTuple[@"MinLon"] doubleValue];
    
    deltaLatitude = (deltaLatitude>0.001)?deltaLatitude:0.001;
    deltaLongitude = (deltaLongitude>0.001)?deltaLongitude:0.001;
    
    mapSpan.latitudeDelta = deltaLatitude * 1.5;
    mapSpan.longitudeDelta = deltaLongitude * 1.5;
    
    return MKCoordinateRegionMake(mapCenter, mapSpan);
}

-(void)setUpMap {
    
    if(_visiblePins) {
        [_mapView removeAnnotations:_visiblePins];
    }
    
    MKCoordinateRegion mapRegion = [self mapAreaContainingParks:_visibleParks];
    _mapView.region = mapRegion;
    
    self.visiblePins = [_visibleParks map:^(NSDictionary *parkInfo) {
        return annotationForPark(parkInfo);
    }];
    
    [_mapView addAnnotations:_visiblePins];
}

#pragma mark - MapView methods

// returns pin
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(ParkMapPin *)annotation {
    MKAnnotationView *pinView = mapPinForPark(annotation);
    pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:imageForParkType(annotation.type)];
    return pinView;
}

#pragma mark - Filtering Methods

-(void)filterVisibleParksByTag:(NSString *)tag {
    if([@"All" isEqualToString:tag]) {
        self.visibleParks = [_originalParks copy];
    }
    else {
        self.visibleParks = [_originalParks filter:^(NSDictionary *parkInfo) {
            NSArray *tagArray = parkInfo[@"tags"];
            BOOL tagFound = NO;
            for( NSString *arrayTag in tagArray ) {
                if([tag isEqualToString:arrayTag]) {
                    tagFound = YES;
                    break;
                }
            }
            return tagFound;
        }];
    }
    [self setUpMap];
}

-(NSArray *)tagsToDisplay {
    NSArray *initialTagsArray = @[];
    NSArray *tagsArray = [_originalParks reduce:initialTagsArray reductor:^NSArray *(NSArray *accum, NSDictionary *element) {
        NSArray *parkTags = element[@"tags"];
        NSSet *setOfTags = [NSSet setWithArray:accum];
        setOfTags = [setOfTags setByAddingObjectsFromArray:parkTags];
        return [setOfTags allObjects];
    }];
    NSArray *tagsToUse = @[@"All"];
    
    return [tagsToUse arrayByAddingObjectsFromArray:tagsArray];
}

#pragma mark - TableView methods for tag picker

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _parkTags.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagSelector"];
    if(nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagSelector"];
    }
    cell.textLabel.text = _parkTags[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filterTag = _parkTags[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self filterVisibleParksByTag:filterTag];
    });
}

@end
