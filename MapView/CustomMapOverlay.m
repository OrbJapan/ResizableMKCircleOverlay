//
//  CustomMapOverlay.m
//  MapView
//
//  Modified by Orb on 3/27/14.
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
// Special thanks to: https://github.com/yickhong/YHMapDemo/tree/master/YHMapDemo
//


#import "CustomMapOverlay.h"

@implementation CustomMKCircleOverlay
@synthesize delegate;
@synthesize MINDIS;
@synthesize MAXDIS;
@synthesize circlebounds;

#define MINDISTANCE 100.0
#define MAXDISTANCE 2000.0

double radius;
double mapRadius;

-(id)initWithCircle:(MKCircle *)circle withRadius:(double)radius withMin:(int)min withMax:(int)max{
    self = [super initWithCircle:circle];
    if(max > min && min > 0){
        MINDIS = min;
        MAXDIS = max;
    }else if(min > 0){
        NSLog(@"Max distance smaller than Min");
        MINDIS = min;
        MAXDIS = min;
    }else{
        NSLog(@"Trying to set a negative radius--Using Default");
        MINDIS = MINDISTANCE;
        MAXDIS = MAXDISTANCE;
    }
    [self commonInit];
    if(radius > 0){
        mapRadius = radius;
    }
    return self;
}

-(id)initWithCircle:(MKCircle *)circle withRadius:(double)radius{
    self = [super initWithCircle:circle];
    MINDIS = MINDISTANCE;
    MAXDIS = MAXDISTANCE;
    [self commonInit];
    if(radius > 0){
        mapRadius = radius;
    }
    return self;
}

-(id)initWithCircle:(MKCircle *)circle{
    
    self = [super initWithCircle:circle];
    MINDIS = MINDISTANCE;
    MAXDIS = MAXDISTANCE;
    [self commonInit];
    return self;
}

-(void)commonInit{
    UIImage* img = [UIImage imageNamed:@"redCircledotted.png"];
    imageView = [[UIImageView alloc] initWithImage:img];
    imageView.opaque = YES;
    imageView.alpha = .25;
    [self addSubview:imageView];
}

-(void)setCircleOffset:(double)newOffset{
    //NSLog(@"%f", radius);
    mapRadius = newOffset * MKMapPointsPerMeterAtLatitude([[self overlay] coordinate].latitude);
    if(mapRadius > MAXDIS){
        mapRadius = MAXDIS;
    }else if(mapRadius < MINDIS){
        mapRadius = MINDIS;
    }
    [self setNeedsDisplayInRect:[self bounds]];
}

-(double)getCircleOffset{
    return mapRadius/MKMapPointsPerMeterAtLatitude([[self overlay] coordinate].latitude);
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)ctx{
    
    MKMapPoint mpoint = MKMapPointForCoordinate([[self overlay] coordinate]);
    
    circlebounds = MKMapRectMake(mpoint.x - mapRadius, mpoint.y - mapRadius, mapRadius *2, mapRadius *2);
    CGRect overlayRect = [self rectForMapRect:circlebounds];

    if(imageView){
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.frame = overlayRect;            
        });
    }
    [self.delegate onRadiusChange:mapRadius];
}

@end
