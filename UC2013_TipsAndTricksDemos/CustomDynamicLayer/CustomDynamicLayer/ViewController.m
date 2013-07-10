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

#import "ViewController.h"
#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create an instance of a tiled map service layer
    // add it to the mapView
	AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:kTiledMapServiceURL]];
	[self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
    
    // add custom dynamic layer
    AGSEnvelope *fullEnvelope = [AGSEnvelope envelopeWithXmin:-117.199967 ymin:34.054694 xmax:-117.192388 ymax:34.060230 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    self.customDynamicLayer = [[CustomDynamicLayer alloc] initWithFullEnvelope:fullEnvelope];
    [self.mapView addMapLayer:self.customDynamicLayer withName:@"Custom Dynamic Layer"];

    // zoom to redlands
    AGSEnvelope *redlandsEnv = [AGSEnvelope envelopeWithXmin:-117.220933 ymin:34.001250 xmax:-117.150308 ymax:34.093062 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [self.mapView zoomToEnvelope:redlandsEnv animated:YES];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
