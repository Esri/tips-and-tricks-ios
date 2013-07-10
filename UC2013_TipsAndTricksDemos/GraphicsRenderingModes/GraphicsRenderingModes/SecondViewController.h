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

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *annotateButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rotateButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) AGSTiledMapServiceLayer *tiledLayer;
@property (strong, nonatomic) AGSGraphicsLayer* graphicsLayer;
@property (strong, nonatomic) AGSMutableEnvelope *envelope;
@property (strong, nonatomic) NSTimer *rotateTimer;
@property (strong, nonatomic) NSTimer *graphicsTimer;
@property (strong, nonatomic) AGSMutableMultipoint *multipoint;
@property (assign, nonatomic) int GRAPHICS_COUNT;

- (IBAction)refreshAction:(id)sender;
- (IBAction)rotateAction:(id)sender;
- (IBAction)annotateAction:(id)sender;
- (IBAction)toggleRenderingModeAction:(id)sender;

@end
