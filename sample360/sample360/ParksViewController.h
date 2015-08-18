//
//  ViewController.h
//  sample360
//
//  Created by Chris Woodard on 8/2/15.
//  Copyright (c) 2015 CW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ParksViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

