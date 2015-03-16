/*
 * Copyright (C) 2005-2010 Skyhook Wireless, Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted subject to the following:
 *
 * * Use and redistribution is subject to the Software License and Development
 * Agreement, available at
 * <a href="http://www.skyhookwireless.com">www.skyhookwireless.com</a>
 *
 * * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SHGeoUtils : NSObject
{
}

/**
 Generates a heat map image for the specified map view.
 
 There should be a one-to-one correspondence between the location and weight elements.
 A nil weight parameter implies an even weight distribution.
 
 @params
 mapView: Map view representing the heat map area.
 boost: heat boost value
 locations: array of CLLocation objects representing the data points
 weights: array of NSNumber integer objects representing the weight of each point
 
 @returns
 UIImage object representing the heatmap for the map region.
 */
+ (UIImage *)heatMapForMapView:(MKMapView *)mapView
                         boost:(float)boost
                     locations:(NSArray *)locations
                       weights:(NSArray *)weights;

/**
 Generates a heat map image for the specified rectangle.
 
 There should be a one-to-one correspondence between the location and weight elements.
 A nil weight parameter implies an even weight distribution.
 
 @params
 @rect: region frame
 boost: heat boost value
 points: array of NSValue CGPoint objects representing the data points
 weights: array of NSNumber integer objects representing the weight of each point
 
 @returns
 UIImage object representing the heatmap for the specified region.
 */
+ (UIImage *)heatMapWithRect:(CGRect)rect
                       boost:(float)boost
                      points:(NSArray *)points
                     weights:(NSArray *)weights;

/**
 Generates a heat map image for the specified rectangle.
 
 There should be a one-to-one correspondence between the location and weight elements.
 A nil weight parameter implies an even weight distribution.
 
 @params
 @rect: region frame
 boost: heat boost value
 points: array of NSValue CGPoint objects representing the data points
 weights: array of NSNumber integer objects representing the weight of each point
 weightsAdjustmentEnabled: set YES for weight balancing and normalization
 groupingEnabled: set YES for tighter visual grouping of dense areas
 
 @returns
 UIImage object representing the heatmap for the specified region.
 */
+ (UIImage *)heatMapWithRect:(CGRect)rect
                       boost:(float)boost
                      points:(NSArray *)points
                     weights:(NSArray *)weights
    weightsAdjustmentEnabled:(BOOL)weightsAdjustmentEnabled
             groupingEnabled:(BOOL)groupingEnabled;


@end