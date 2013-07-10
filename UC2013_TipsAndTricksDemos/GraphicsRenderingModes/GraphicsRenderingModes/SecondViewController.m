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

#import "SecondViewController.h"
#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create an instance of a tiled map service layer
    // add it to the mapView
    
	self.tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:kTiledMapServiceURL]];
	[self.mapView addMapLayer:self.tiledLayer withName:@"Tiled Layer"];
    
    // allow rotating by pinching
    self.mapView.allowRotationByPinching = YES;
    
    //set graphic count
    self.GRAPHICS_COUNT = 100;
}

#pragma mark - Action Methods

- (IBAction)toggleRenderingModeAction:(id)sender {
    
    //enable buttons
    [self.annotateButton setEnabled:YES];
    [self.rotateButton setEnabled:YES];
    [self.refreshButton setEnabled:YES];
    
    //remove graphics layer from map
    [self.mapView removeMapLayer:self.graphicsLayer];
    
    // initialize graphics layer with selected rendering mode
    if ([sender selectedSegmentIndex] == 0) {
        // graphics layer in static mode
        self.graphicsLayer  = [[AGSGraphicsLayer alloc] initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeStatic];
    }
    else if ([sender selectedSegmentIndex] == 1) {
        // graphics layer in static mode
        self.graphicsLayer  = [[AGSGraphicsLayer alloc] initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    }

    //create unique value renderer for graphics layer
    AGSUniqueValueRenderer* uvRenderer = [[AGSUniqueValueRenderer alloc] init];
    NSMutableArray *uValues = [[NSMutableArray alloc] init];
    
    AGSUniqueValue *uqv = [AGSUniqueValue uniqueValueWithValue:@"1" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"BlueShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"2" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"ShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"3" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GoldShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"4" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GreenShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"5" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"LightBlueShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"6" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"LightGreenShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"7" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"PurpleShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"8" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"RedShinyPin"]];
    [uValues addObject:uqv];
    uqv = [AGSUniqueValue uniqueValueWithValue:@"9" symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"RedShinyPin2"]];
    [uValues addObject:uqv];
    uvRenderer.uniqueValues = uValues;
    uvRenderer.fields = @[@"Color"];
    self.graphicsLayer.renderer = uvRenderer;
    
    // add graphics layer to map
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
}

- (IBAction)annotateAction:(id)sender {
    
    if(self.graphicsTimer!=nil){
        [self.graphicsTimer invalidate];
        self.graphicsTimer = nil;
        [sender setImage:[UIImage imageNamed:@"play"]];
    }else {
        self.envelope = ((AGSMutableEnvelope*)[self.mapView.visibleAreaEnvelope mutableCopy]);
        [self.envelope  expandByFactor:0.5];
        self.graphicsTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(doGraphics) userInfo:nil repeats:YES];
        [sender setImage:[UIImage imageNamed:@"pause"]];
    }
}

- (IBAction)rotateAction:(id)sender {
    
    if(self.rotateTimer!=nil) {
        [self.rotateTimer invalidate];
        self.rotateTimer = nil;
    }else {
        self.rotateTimer = [NSTimer scheduledTimerWithTimeInterval:0.075 target:self selector:@selector(doRotate) userInfo:nil repeats:YES];
    }
}
- (void) doRotate {
    [self.mapView setRotationAngle: (self.mapView.rotationAngle+1) animated:YES];
}

- (double) randomNumberBetween:(int)min and:(int)max{
    double f = (double)rand() / RAND_MAX;
    f = min + f * (max - min);
    return f;
}

- (void) doGraphics {
    
    double x =  [self randomNumberBetween:self.envelope.xmax and:self.envelope.xmin];
    double y = [self randomNumberBetween:self.envelope.ymax and:self.envelope.ymin];
    
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference] symbol:nil attributes:@{@"Color": [@((int)[self randomNumberBetween:0 and:10]) stringValue ]} infoTemplateDelegate:nil];
    [self.graphicsLayer addGraphic:g];
    if(self.graphicsLayer.graphicsCount>self.GRAPHICS_COUNT){
        [self.graphicsLayer removeGraphic:((AGSGraphic*)(self.graphicsLayer.graphics)[0])];
    }
}

- (IBAction)refreshAction:(id)sender {
    
    //invalidate graphics timer
    [self.graphicsTimer invalidate];
    self.graphicsTimer = nil;
    
    //invalidate rotate timer
    [self.rotateTimer invalidate];
    self.rotateTimer = nil;
    
    //reset angle of mapView
    [self.mapView setRotationAngle:0 animated:YES];
    
    //remove all graphics
    [self.graphicsLayer removeAllGraphics];
        
    //reset annotate button
    [self.annotateButton setImage:[UIImage imageNamed:@"play"]];
    
    //zoom to full envelope
    [self.mapView zoomToEnvelope:self.tiledLayer.fullEnvelope animated:YES];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
