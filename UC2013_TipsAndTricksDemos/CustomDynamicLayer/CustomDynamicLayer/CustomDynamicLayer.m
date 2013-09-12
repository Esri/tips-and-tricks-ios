/*
 Copyright 2013 Esri
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CustomDynamicLayer.h"

@interface CustomDynamicLayer (){
    BOOL _hasDrawn;
}
@property (nonatomic, strong, readwrite) AGSEnvelope *fullEnvelope;
@property (nonatomic, strong, readwrite) AGSSpatialReference *spatialReference;
@end

@implementation CustomDynamicLayer
@synthesize fullEnvelope = _fullEnvelope;
@synthesize spatialReference = _spatialReference;

#pragma mark - Init Methods

- (id)initWithFullEnvelope:(AGSEnvelope*)fullEnvelope {
    self = [super init];
    if (self) {
        _spatialReference = fullEnvelope.spatialReference;
        _fullEnvelope = fullEnvelope;
        [self layerDidLoad];
    }
    return self;
}

-(void)mapDidUpdate:(AGSMapUpdateType)updateType{
    // this handles if the layer gets added to another map
    if (updateType == AGSMapUpdateTypeLayerAdded){
        _hasDrawn = NO;
    }
}

#pragma mark - Request Image

-(void)requestImageWithWidth:(NSInteger)width height:(NSInteger)height envelope:(AGSEnvelope*)env timeExtent:(AGSTimeExtent*)timeExtent {
    
    // no longer need to do anything once we've drawn
    // the map control will keep the last image around
    if (_hasDrawn){
        return;
    }
    
    // only draw if the requested envelope intersects the envelope of the
    // georeferenced image
    if (![env intersectionWithEnvelope:self.fullEnvelope]){
        return;
    }
    
    // match spatial reference
    if (self.spatialReference && ![self.spatialReference isEqualToSpatialReference:env.spatialReference]){
        return;
    }
    
    // draw once
    UIImage *img = [UIImage imageNamed:@"esri_campus"];
    [self setImageData:UIImagePNGRepresentation(img) forEnvelope:self.fullEnvelope];
    _hasDrawn = YES;
    
}

@end
