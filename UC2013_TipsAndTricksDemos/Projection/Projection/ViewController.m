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
#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"

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
    
    // create an instance of graphics layer and add to map
    self.graphicsLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];

    // zoom to san diego
    AGSEnvelope *sanDiegoEnvelope = [AGSEnvelope envelopeWithXmin:-13054262.247685 ymin:3842027.758563 xmax:-13021719.330385 ymax:3868472.771851 spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [self.mapView zoomToEnvelope:sanDiegoEnvelope animated:YES];
}

#pragma mark - Action Methods

- (IBAction)addGraphic1Action:(id)sender {
    
    // remove all graphics
    [self.graphicsLayer removeAllGraphics];
    
    // create picture marker symbol
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"ShinyPin"];
    
    // create point for san diego convention center
    AGSPoint *pointWGS84 = [AGSPoint pointWithX:-117.1643 y:32.7089 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    // create graphic and add to graphics layer
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:pointWGS84 symbol:pms attributes:nil infoTemplateDelegate:nil];
    [self.graphicsLayer addGraphic:graphic];
    
    // zoom to graphic layer
    [self.mapView zoomToGeometry:self.graphicsLayer.fullEnvelope withPadding:50 animated:YES];
}


- (IBAction)addGraphic2Action:(id)sender {
    
    // remove all graphics
    [self.graphicsLayer removeAllGraphics];
    
    // create picture marker symbol
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"ShinyPin"];
    
    // create point for san diego convention center
    AGSPoint *pointWGS84 = [AGSPoint pointWithX:-117.1643 y:32.7089 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    // project wgs 1984 geometry to web mercator
    AGSGeometry *pointWebMercator = AGSGeometryGeographicToWebMercator(pointWGS84);
    
    // create graphic and add to graphics layer
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:pointWebMercator symbol:pms attributes:nil infoTemplateDelegate:nil];
    [self.graphicsLayer addGraphic:graphic];
    
    // zoom to graphic layer
    [self.mapView zoomToGeometry:self.graphicsLayer.fullEnvelope withPadding:50 animated:YES];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
