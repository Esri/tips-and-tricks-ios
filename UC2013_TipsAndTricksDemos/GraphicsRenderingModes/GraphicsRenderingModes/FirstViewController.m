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

#import "FirstViewController.h"
#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"

#pragma mark UIColor (Random)

@interface UIColor (Random)

+ (UIColor *) randomColor;

@end

@implementation UIColor (Random)

+ (UIColor *) randomColor {
	CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end

#pragma mark - First View Controller

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create an instance of a tiled map service layer
    // add it to the mapView
	AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:kTiledMapServiceURL]];
	[self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
    
    //zoom to california
    AGSEnvelope *californiaEnv = [AGSEnvelope envelopeWithXmin:-124.409721 ymin:32.534157 xmax:-114.131212 ymax:42.009519 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [self.mapView zoomToEnvelope:californiaEnv animated:YES];
}

#pragma mark - Add Graphics From FeatureSet file

- (void)addGraphicsFromFeatureSetFile {
    
    // update activity indicator
    [self performSelectorInBackground:@selector(updateActivityIndicator) withObject:nil];
    
    // get path of feature set file
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FeatureSet"];
    
    // if file exist then read and create AGSFeatureSet from it
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
        NSError *error = nil;
        NSString *featureSetString = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:&error];
        if (!error) {
            
            NSDictionary *featureSetDictionary = (NSDictionary *)[featureSetString ags_JSONValue];
            AGSFeatureSet *featureSet = [[AGSFeatureSet alloc] initWithJSON:featureSetDictionary];
            
            // initialize graphics array
            self.graphics = [NSMutableArray array];
                        
            // loop through all graphics, set symbol and to graphics array
            for (AGSGraphic *graphic in featureSet.features) {
                graphic.symbol = [self graphicSymbol];
                [self.graphics addObject:graphic];
            }
                        
            // add graphics to graphics layer
            [self.graphicsLayer addGraphics:self.graphics];
        }
    }
        
    // update activity indicator
    [self performSelectorInBackground:@selector(updateActivityIndicator) withObject:nil];
}

#pragma mark - Toggle Graphics Rendering Mode

- (IBAction)toggleRenderingMode:(id)sender {
    
    // remove all graphics
    [self.graphicsLayer removeAllGraphics];
    
    // remove graphics layer from map
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
    
    // add graphics layer to map
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
    
    // if graphics are present then add
    // else get them from feature set file
    if (self.graphics) {
        [self.graphicsLayer addGraphics:self.graphics];
    }
    else {
        [self performSelectorInBackground:@selector(addGraphicsFromFeatureSetFile) withObject:nil];
    }
}

#pragma mark - Simple Fill Symbol

- (AGSSimpleFillSymbol*)graphicSymbol {
    AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbol];
    sfs.color = [UIColor randomColor];
    return sfs;
}

#pragma mark - Update Activity Indicator

- (void)updateActivityIndicator {
    if ([self.activityIndicatorView isHidden]) {
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
    }
    else {
        [self.activityIndicatorView stopAnimating];
    }
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
