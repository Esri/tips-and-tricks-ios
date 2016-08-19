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
#define kTiledMapServiceURL @"https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"

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
    
    //add graphics layer
    self.graphicsLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
    
    //zoom to predefined extend with known spatial reference of the map
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:-1131596.019761 ymin:3893114.069099 xmax:3926705.982140 ymax:7977912.461790 spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [self.mapView zoomToEnvelope:envelope animated:YES];
}

#pragma mark - Toggle Freehand Sketch

- (IBAction)toggleFreehandSketchAction:(id)sender {
        
    if ([self.freehandSketchControl selectedSegmentIndex] == 0) {
        
        // create a custom view and overlay the mapview
        self.drawView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.drawView.translatesAutoresizingMaskIntoConstraints = NO;
        self.drawView.backgroundColor = [UIColor clearColor];
        
        // setup the gesture recognizer
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        panGR.maximumNumberOfTouches = 1;
        panGR.minimumNumberOfTouches = 1;
        [self.drawView addGestureRecognizer:panGR];        
        [self.view addSubview:self.drawView];
        
        // setup the constraints
        NSDictionary *views = @{@"drawView" : self.drawView};
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[drawView]-0-|" options:0 metrics:nil views:views];
        [self.view addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[drawView]-0-|" options:0 metrics:nil views:views];
        [self.view addConstraints:constraints];
        
        // enable clear button
        [self.clearButton setEnabled:YES];
        
    } else {
        
        // remove draw view
        [self.drawView removeFromSuperview];
        self.drawView = nil;
        
        // disable clear button
        [self.clearButton setEnabled:NO];
    }
}

- (void)panned:(id)sender {
    
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer*)sender;
    CGPoint loc = [panGR locationInView:self.drawView];
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        
        self.lastPoint = loc;
        
        self.polyline = [[AGSMutablePolyline alloc] init];
        [self.polyline addPathToPolyline];
        
        AGSSimpleLineSymbol *symbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:3.0];
        self.drawGraphic = [AGSGraphic graphicWithGeometry:self.polyline symbol:symbol attributes:nil infoTemplateDelegate:nil];
        [self.graphicsLayer addGraphic:self.drawGraphic];
    }
    else if (panGR.state == UIGestureRecognizerStateChanged) {
        if (CGPointEqualToPoint(self.lastPoint, loc))
            return;
        
        self.lastPoint = loc;
        [self.polyline addPointToPath:[self.mapView toMapPoint:loc]];
        self.drawGraphic.geometry = self.polyline;
    }
    else if (panGR.state == UIGestureRecognizerStateEnded) {
        self.polyline = nil;
    }
}

- (IBAction)clearAction:(id)sender {
    // remove all graphics
    [self.graphicsLayer removeAllGraphics];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
