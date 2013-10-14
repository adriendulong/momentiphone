//
//  MKMapView+ZoomLevel.h
//
//  Created Troy on January 22, 2010 
//  http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
