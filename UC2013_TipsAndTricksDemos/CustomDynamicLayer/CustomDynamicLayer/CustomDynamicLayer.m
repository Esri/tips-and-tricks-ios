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

@interface CustomDynamicLayer ()
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

#pragma mark - Request Image

-(void)requestImageWithWidth:(NSInteger)width height:(NSInteger)height envelope:(AGSEnvelope*)env timeExtent:(AGSTimeExtent*)timeExtent {    
    
    // get an image
    UIImage *img = [UIImage imageNamed:@"esri_campus"];
    
    // if request envelope instersect with full envelope 
    // of layer then only set image data
    if ([env intersectsWithEnvelope:self.fullEnvelope]) {
        [self setImageData:UIImagePNGRepresentation(img) forEnvelope:self.fullEnvelope];       
    }
    else {
        [self setImageData:nil forEnvelope:self.fullEnvelope];
    }
}

@end
