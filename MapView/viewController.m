//
//  jp_co_orbViewController.m
//  MapView
//
//  Created by Michael on 3/3/14.
//  Copyright (c) 2014 Orb. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "viewController.h"
#import "WildcardGestureRecognizer.h"
#import "CustomMapOverlay.h"


@interface viewController ()

@end

@implementation viewController

/* Default radius size in PX*/
double const circleRadius = 0;

/* Default Location */
#define TOKYO_LATITUDE 35.6895
#define TOKYO_LONGITUDE 139.6917
#define ZOOM_DISTANCE 50
#define DEFAULT_RADIUS 100;


double oldoffset;
double setRadius = DEFAULT_RADIUS;

bool panEnabled = YES;
CLLocationCoordinate2D droppedAt;
MKMapPoint lastPoint;
CustomMKCircleOverlay *circleView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    droppedAt = CLLocationCoordinate2DMake(TOKYO_LATITUDE, TOKYO_LONGITUDE);
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(droppedAt,ZOOM_DISTANCE,ZOOM_DISTANCE);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    /* Add Custom MKCircle with Annotation*/
    [self addCircle];

    /* Setup Touch listener for custom circle */
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self.mapView];
        
        CLLocationCoordinate2D coord = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
        
        MKMapRect mapRect = [circleView circlebounds];
        
        double xPath = mapPoint.x - mapRect.origin.x;
        double yPath = mapPoint.y - mapRect.origin.y;
        
        /* Test if the touch was within the bounds of the circle */
        if(xPath >= 0 && yPath >= 0 && xPath < mapRect.size.width && yPath < mapRect.size.height){
            //NSLog(@"Disable Map Panning");
            
            /*
             This block is to ensure scrollEnabled = NO happens before the any move event.
             */
            __block int t = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                t = 1;
                self.mapView.scrollEnabled = NO;
                panEnabled = NO;
                oldoffset = [circleView getCircleRadius];
            });


            
        }else{
            self.mapView.scrollEnabled = YES;
        }
        lastPoint = mapPoint;
    };
    tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
        if(!panEnabled && [event allTouches].count == 1){
            UITouch *touch = [touches anyObject];
            CGPoint p = [touch locationInView:self.mapView];
            
            CLLocationCoordinate2D coord = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
            MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
            
            MKMapRect mRect = self.mapView.visibleMapRect;
            MKMapRect circleRect = [circleView circlebounds];
            //NSLog(@"radius: %f", [circleView getCircleRadius]);
            
            /* Check if the map needs to zoom */
            if(circleRect.size.width > mRect.size.width *.95){
                MKCoordinateRegion region;
                //Set Zoom level using Span
                MKCoordinateSpan span;
                region.center=droppedAt;
                span.latitudeDelta=self.mapView.region.span.latitudeDelta * 2.0;
                span.longitudeDelta=self.mapView.region.span.longitudeDelta * 2.0;
                region.span=span;
                [_mapView setRegion:region animated:TRUE];
            }
            if(circleRect.size.width < mRect.size.width *.25){
                MKCoordinateRegion region;
                //Set Zoom level using Span
                MKCoordinateSpan span;
                region.center=droppedAt;
                span.latitudeDelta=_mapView.region.span.latitudeDelta /3.0002;
                span.longitudeDelta=_mapView.region.span.longitudeDelta /3.0002;
                region.span=span;
                [_mapView setRegion:region animated:TRUE];
            }
            
            
            double meterDistance = (mapPoint.x - lastPoint.x)/MKMapPointsPerMeterAtLatitude(self.mapView.centerCoordinate.latitude)+oldoffset;
            if(meterDistance > 0){
                [circleView setCircleRadius:meterDistance];
            }
        }
    };
    tapInterceptor.touchesEndedCallback = ^(NSSet * touches, UIEvent * event) {
        panEnabled = YES;
        
        //NSLog(@"Enable Map Panning");
        
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.userInteractionEnabled = YES;
    };

    [self.mapView addGestureRecognizer:tapInterceptor];

}

- (void)mapView:(MKMapView *)mapView
        annotationView:(MKAnnotationView *)annotationView
        didChangeDragState:(MKAnnotationViewDragState)newState
        fromOldState:(MKAnnotationViewDragState)oldState {
    if(newState == MKAnnotationViewDragStateStarting){
        panEnabled = YES;
    }
    if (newState == MKAnnotationViewDragStateEnding) {
        droppedAt = annotationView.annotation.coordinate;
        //NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        [self addCircle];
    }

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    [annotationView setDraggable:YES];
    annotationView.pinColor = MKPinAnnotationColorPurple;
    
    [annotationView setSelected:YES animated:YES];
    return [annotationView init];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    circleView = [[[CustomMKCircleOverlay alloc] initWithCircle:(MKCircle *)overlay withRadius:setRadius] init];
    circleView.delegate = self;
    return circleView;
}

-(void)onRadiusChange:(double)radius{
    setRadius = radius;
    
    NSString *distance;
    if(radius > 1000){
        radius /= 1000;
        distance = [NSString stringWithFormat:@"%.02f km", radius];
    }else{
        distance = [NSString stringWithFormat:@"%.f m", radius];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.distanceLabel setText:distance];
    });
}

-(void)addCircle{
    if(point == nil){
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = droppedAt;
        [self.mapView addAnnotation:point];
    }
    if(circle != nil)
        [self.mapView removeOverlay:circle];
    circle = [MKCircle circleWithCenterCoordinate:droppedAt radius:circleRadius];
    [self.mapView addOverlay: circle];
    [circleView setCircleRadius:setRadius];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
