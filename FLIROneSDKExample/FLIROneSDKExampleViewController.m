//
//  FLIROneSDKExampleViewController.m
//  FLIROneSDKExample
//
//  Created by Joseph Colicchio on 5/22/14.
//  Copyright (c) 2014 novacoast. All rights reserved.
//
//  Modified by Nataly Moreno on 2/23/14.
//  Modified and pushed to new repo by Mohit Hingorani on 3/6/2015

#import "FLIROneSDKExampleViewController.h"

#import <FLIROneSDK/FLIROneSDKLibraryViewController.h>

#import <AVFoundation/AVFoundation.h>

#import <FLIROneSDK/FLIROneSDKUIImage.h>

#import "ScanOverViewController.h"

#define ROUND_BUTTON_RADIUS 50

@interface FLIROneSDKExampleViewController ()

//Additions to UI
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

//Colors
@property (nonatomic) UIColor *bg_color;
@property (nonatomic) UIColor *border_color;
@property (nonatomic) UIColor *red_border_color;
@property (nonatomic) UIColor *transparent_color;


//Button to Block Camera View
@property (weak, nonatomic) IBOutlet UIButton *blockView1;
@property (weak, nonatomic) IBOutlet UIButton *blockView2;
@property (weak, nonatomic) IBOutlet UIButton *blockView3;
@property (weak, nonatomic) IBOutlet UIButton *blockView4;
@property (weak, nonatomic) IBOutlet UIButton *blockView5;
@property (weak, nonatomic) IBOutlet UIButton *blockView6;
@property (weak, nonatomic) IBOutlet UIButton *blockView7;
@property (weak, nonatomic) IBOutlet UIButton *blockView8;
@property (weak, nonatomic) IBOutlet UIButton *blockView9;
@property (weak, nonatomic) IBOutlet UIButton *blockView10;
@property (weak, nonatomic) IBOutlet UIButton *blockView11;
@property (weak, nonatomic) IBOutlet UIButton *blockView12;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

/////////////////////////////////////////////////////////////////////////////////////////
//The main viewfinder for the FLIR ONE
@property (weak, nonatomic) IBOutlet UIView *masterImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thermalImageView;
@property (strong, nonatomic) IBOutlet UIImageView *radiometricImageView;
@property (strong, nonatomic) IBOutlet UIButton *thermalButton;
//@property (strong, nonatomic) IBOutlet UIButton *thermal14BitButton;

//labels outlining various camera information
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UILabel *tuningStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *batteryChargingLabel;
@property (strong, nonatomic) IBOutlet UILabel *batteryPercentageLabel;

@property (strong, nonatomic) IBOutlet UILabel *frameCountLabel;

@property (strong, nonatomic) IBOutlet UIButton *paletteButton;

@property (strong, nonatomic) IBOutlet UIButton *emissivityButton;
@property (strong, nonatomic) IBOutlet UIButton *msxButton;

/*@property (strong, nonatomic) UIView *regionView;
@property (strong, nonatomic) UILabel *regionMinLabel;
@property (strong, nonatomic) UILabel *regionMaxLabel;
@property (strong, nonatomic) UILabel *regionAverageLabel;
 */

@property (strong, nonatomic) UIView *hottestPoint;
@property (strong, nonatomic) UILabel *hottestLabel;
@property (strong, nonatomic) UIView *coldestPoint;
@property (strong, nonatomic) UILabel *coldestLabel;


/// additional labels for tile POI  ///////

@property (strong, nonatomic) UIView *tilePoint2;
@property (strong, nonatomic) UILabel *tileLabel2;

@property (strong, nonatomic) UIView *tilePoint5;
@property (strong, nonatomic) UILabel *tileLabel5;

@property (strong, nonatomic) UIView *tilePoint8;
@property (strong, nonatomic) UILabel *tileLabel8;

@property (strong, nonatomic) UIView *tilePoint0;
@property (strong, nonatomic) UILabel *tileLabel0;

//////////////////////////////////////////



@property (strong, nonatomic) NSData *thermalData;
@property (nonatomic) CGSize thermalSize;

//buttons for interacting with the FLIR ONE
//view library
@property (nonatomic, strong) IBOutlet UIButton *libraryButton;
//capture photo
@property (nonatomic, strong) IBOutlet UIButton *capturePhotoButton;
//capture video
@property (nonatomic, strong) IBOutlet UIButton *captureVideoButton;
//swap palettes, button overlays the viewfinder
//@property (nonatomic, strong) UIButton *imageButton;

//data for UI to display
@property (strong, nonatomic) UIImage *thermalImage;
@property (strong, nonatomic) UIImage *radiometricImage;

//@property (strong, nonatomic) FLIROneSDKUIImage *sdkImage;

@property (strong, nonatomic) NSDictionary *spotTemperatures;
@property (strong, nonatomic) FLIROneSDKPalette *palette;
@property (nonatomic) NSUInteger paletteCount;

@property (nonatomic) BOOL connected;

@property (nonatomic) FLIROneSDKTuningState tuningState;

@property (nonatomic) FLIROneSDKBatteryChargingState batteryChargingState;
@property (nonatomic) NSInteger batteryPercentage;

//@property (nonatomic) FLIROneSDKEmissivity *emissivity;
@property (nonatomic) CGFloat emissivity;
@property (nonatomic) FLIROneSDKImageOptions options;

@property (nonatomic) BOOL pixelDataExists;
@property (nonatomic) CGPoint pixelOfInterest;
@property (nonatomic) CGPoint coldPixel;
@property (nonatomic) CGFloat pixelTemperature;
@property (nonatomic) CGFloat coldestTemperature;

////additonal pixel allocations for tiles
@property (nonatomic) CGPoint tilePixel2;
@property (nonatomic) CGFloat tileTemperature2;

@property (nonatomic) CGPoint tilePixel5;
@property (nonatomic) CGFloat tileTemperature5;

@property (nonatomic) CGPoint tilePixel8;
@property (nonatomic) CGFloat tileTemperature8;

@property (nonatomic) CGPoint tilePixel0;
@property (nonatomic) CGFloat tileTemperature0;

//////////////////////////////////////////


@property (nonatomic) BOOL regionDataExists;
@property (nonatomic) CGRect regionOfInterest;
@property (nonatomic) CGFloat regionMinTemperature;
@property (nonatomic) CGFloat regionMaxTemperature;
@property (nonatomic) CGFloat regionAverageTemperature;

@property (nonatomic) BOOL msxDistanceEnabled;

@property (strong, nonatomic) dispatch_queue_t renderQueue;
//@property (strong, nonatomic) NSData *imageData;

@property (nonatomic) NSTimeInterval lastTime;
@property (nonatomic) CGFloat fps;

//capturing video stuff

//if the user is capturing a video or in the process of recording, the camera is "busy", block requests to capture more media
@property (nonatomic) BOOL cameraBusy;

//if there is currently a video being recorded
@property (nonatomic) BOOL currentlyRecording;
//is the image finished recording, and currently wrapping up the file write process?
@property (nonatomic) BOOL savingVideo;

@property (nonatomic) NSInteger frameCount;

@end

@implementation FLIROneSDKExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UI stuff
    self.thermalImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.radiometricImageView.contentMode = UIViewContentModeScaleAspectFit;
	
    /*self.regionView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.regionView];
    self.regionView.backgroundColor = [UIColor greenColor];
    self.regionView.alpha = 0.5;
    
    self.regionMinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.regionMinLabel];
    self.regionMaxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.regionMaxLabel];
    self.regionAverageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.regionAverageLabel];
	 */
    
    self.hottestPoint = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.hottestPoint];
    self.hottestPoint.backgroundColor = [UIColor redColor];
    self.hottestPoint.alpha = 0.5;
    self.hottestLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.hottestLabel];
    
    self.coldestPoint = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.coldestPoint];
    self.coldestPoint.backgroundColor = [UIColor blueColor];
    self.coldestPoint.alpha = 0.5;
    self.coldestLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.coldestLabel];
    
    ////////////additional tile points
    self.tilePoint2 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tilePoint2];
    self.tilePoint2.backgroundColor = [UIColor greenColor];
    self.tilePoint2.alpha = 0.5;
    self.tileLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tileLabel2];
    
    self.tilePoint5 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tilePoint5];
    self.tilePoint5.backgroundColor = [UIColor greenColor];
    self.tilePoint5.alpha = 0.5;
    self.tileLabel5 = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tileLabel5];
    
    self.tilePoint8 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tilePoint8];
    self.tilePoint8.backgroundColor = [UIColor greenColor];
    self.tilePoint8.alpha = 0.5;
    self.tileLabel8 = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tileLabel8];

    self.tilePoint0 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tilePoint0];
    self.tilePoint0.backgroundColor = [UIColor greenColor];
    self.tilePoint0.alpha = 0.5;
    self.tileLabel0 = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.masterImageView addSubview:self.tileLabel0];

    

    
    

    
	
	//My Modifications to UI Stuff
	[self.titleLabel setText:self.chosen_scan_mode];
	
	self.bg_color = [[UIColor alloc] initWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0];
	self.border_color = [[UIColor alloc] initWithRed: 65.0 / 255.0
											   green: 120.0 / 255.0
												blue: 219.0 / 255.0
											   alpha: 1.0];
	self.red_border_color  = [[UIColor alloc] initWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.7];
	self.transparent_color = [[UIColor alloc] initWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0];

	
	//Set Background Color
	self.view.backgroundColor = self.bg_color;
	
	//Set Up the Back Button
	self.backButton = [self makeCircularButton:self.backButton withImage:@"big_backArrow.png" atXLoc:210 atYLoc:480];
	[self.backButton addTarget:self action:@selector(goToScanOverview:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.backButton];
	
	if([self.chosen_scan_mode isEqual: @"Scan Head"])
	{
		//[[myButton layer] setBorderWidth:2.0f];
		//[[myButton layer] setBorderColor:[UIColor greenColor].CGColor];
	}
	if([self.chosen_scan_mode isEqual: @"Scan Right Arm"])
	{
		//2, 5, 8, 9
		[self.blockView8 setBackgroundColor:self.transparent_color];
		[[self.blockView8 layer] setBorderWidth:0.7f];
		[[self.blockView8 layer] setBorderColor:self.red_border_color.CGColor];
		self.blockView8.layer.zPosition = 1;
		
		[self.masterImageView sendSubviewToBack:self.blockView2];
		[self.masterImageView sendSubviewToBack:self.blockView5];
		[self.masterImageView sendSubviewToBack:self.blockView8];
		[self.masterImageView sendSubviewToBack:self.blockView9];

		[self.masterImageView bringSubviewToFront:self.blockView1];
		[self.masterImageView bringSubviewToFront:self.blockView3];
		[self.masterImageView bringSubviewToFront:self.blockView4];
		[self.masterImageView bringSubviewToFront:self.blockView6];
		[self.masterImageView bringSubviewToFront:self.blockView7];
		[self.masterImageView bringSubviewToFront:self.blockView10];
		[self.masterImageView bringSubviewToFront:self.blockView11];
		[self.masterImageView bringSubviewToFront:self.blockView12];
	}
	if([self.chosen_scan_mode isEqual: @"Scan Left Arm"])
	{
		//2, 5, 8, 7
		[self.blockView8 setBackgroundColor:self.transparent_color];
		[[self.blockView8 layer] setBorderWidth:0.7f];
		[[self.blockView8 layer] setBorderColor:self.red_border_color.CGColor];
		self.blockView8.layer.zPosition = 1;
		
		[self.masterImageView sendSubviewToBack:self.blockView2];
		[self.masterImageView sendSubviewToBack:self.blockView5];
		[self.masterImageView sendSubviewToBack:self.blockView7];
		[self.masterImageView sendSubviewToBack:self.blockView8];

		[self.masterImageView bringSubviewToFront:self.blockView1];
		[self.masterImageView bringSubviewToFront:self.blockView3];
		[self.masterImageView bringSubviewToFront:self.blockView4];
		[self.masterImageView bringSubviewToFront:self.blockView6];
		[self.masterImageView bringSubviewToFront:self.blockView9];
		[self.masterImageView bringSubviewToFront:self.blockView10];
		[self.masterImageView bringSubviewToFront:self.blockView11];
		[self.masterImageView bringSubviewToFront:self.blockView12];
	}
	if([self.chosen_scan_mode isEqual: @"Scan Right Leg"] ||
	   [self.chosen_scan_mode isEqual: @"Scan Left Leg"])
	{
		//2, 5, 8, 11
		[self.blockView8 setBackgroundColor:self.transparent_color];
		[[self.blockView8 layer] setBorderWidth:0.7f];
		[[self.blockView8 layer] setBorderColor:self.red_border_color.CGColor];
		self.blockView8.layer.zPosition = 1;
		
		[self.masterImageView sendSubviewToBack:self.blockView2];
		[self.masterImageView sendSubviewToBack:self.blockView5];
		[self.masterImageView sendSubviewToBack:self.blockView8];
		[self.masterImageView sendSubviewToBack:self.blockView11];

		[self.masterImageView bringSubviewToFront:self.blockView1];
		[self.masterImageView bringSubviewToFront:self.blockView3];
		[self.masterImageView bringSubviewToFront:self.blockView4];
		[self.masterImageView bringSubviewToFront:self.blockView6];
		[self.masterImageView bringSubviewToFront:self.blockView7];
		[self.masterImageView bringSubviewToFront:self.blockView9];
		[self.masterImageView bringSubviewToFront:self.blockView10];
		[self.masterImageView bringSubviewToFront:self.blockView12];
	}

	
	///////////////////////////////////////////////////////////////////////////////////////////
    //center of screen, half width half height, offset by width/4, height/4
    self.regionOfInterest = CGRectMake(0.25, 0.25, 0.5, 0.5);
    
    //create a queue for rendering
    self.renderQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //set the options to MSX blended
    self.options = FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
    
    
    [[FLIROneSDKStreamManager sharedInstance] addDelegate:self];
    
    [[FLIROneSDKStreamManager sharedInstance] setImageOptions:self.options];
    
    self.cameraBusy = NO;
    
    self.paletteCount = 0;
    
    [self updateUI];
}

//My Additional UI Functions
//code from: http://stackoverflow.com/questions/6952755/how-to-create-a-round-button/6954024#6954024
- (UIButton*)makeCircularButton:(UIButton*)abutton withImage:(NSString*)imName atXLoc:(NSInteger)xLoc atYLoc:(NSInteger)yLoc {
	abutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[abutton setImage:[UIImage imageNamed:imName] forState:UIControlStateNormal];
	abutton.frame = CGRectMake(xLoc, yLoc, ROUND_BUTTON_RADIUS, ROUND_BUTTON_RADIUS);
	abutton.clipsToBounds = YES;
	abutton.layer.cornerRadius = ROUND_BUTTON_RADIUS/2.0f;
	abutton.layer.borderColor = self.border_color.CGColor;
	abutton.layer.borderWidth = 2.0f;
	return abutton;
}

- (void)goToScanOverview:(UIButton*)tappedButton{
	//NSLog(@"goToSelectPatient Method Called");
	
	ScanOverViewController *scanView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanOverView"];
	
	scanView.prev_view = self.prev_view;
	[self.navigationController pushViewController:scanView animated:YES];
}

//End Additional UI Functions

- (IBAction) switchPalette:(UIButton *)button {
    NSInteger paletteIndex = [[[FLIROneSDKPalette palettes] allValues] indexOfObject:self.palette];
    if(paletteIndex >= 0) {
        self.paletteCount = paletteIndex;
    }
    self.paletteCount = ((self.paletteCount+1) % [[FLIROneSDKPalette palettes] count]);
    FLIROneSDKPalette *palette = [[[FLIROneSDKPalette palettes] allValues] objectAtIndex:self.paletteCount];
    
    [[FLIROneSDKStreamManager sharedInstance] setPalette:palette];
}

- (void) updateUI {
    //updates the UI based on the state of the sled
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.thermalImageView setImage:self.thermalImage];
		
		//NEW CODE COPIED FROM RADIOMETRIC IMAGE
		if(self.thermalData && self.options & FLIROneSDKImageOptionsThermalRadiometricKelvinImage) {
			//find hottest point
			//self.hottestPoint.hidden = NO;
			
			@synchronized(self) {
				[self performTemperatureCalculations];
			}
			
			self.pixelDataExists = true;
			self.regionDataExists = true;
			
		} else {
			self.pixelDataExists = false;
			self.regionDataExists = false;
		}
		
		
		
        [self.radiometricImageView setImage:self.radiometricImage];
		
		
        /*if(self.thermalData && self.options & FLIROneSDKImageOptionsThermalRadiometricKelvinImage) {
            //find hottest point
            //self.hottestPoint.hidden = NO;

            @synchronized(self) {
                [self performTemperatureCalculations];
            }
            
            self.pixelDataExists = true;
            self.regionDataExists = true;
            
        } else {
            self.pixelDataExists = false;
            self.regionDataExists = false;
        }*/
        
        if(self.palette)
            [self.paletteButton setTitle:[NSString stringWithFormat:@"%@", [self.palette name]] forState:UIControlStateNormal];
        else
            [self.paletteButton setTitle:@"N/A" forState:UIControlStateNormal];
        
        if(self.connected) {
            [self.connectionLabel setText:@"Connected"];
            [self.capturePhotoButton setEnabled:!self.cameraBusy];
            [self.captureVideoButton setEnabled:(!self.cameraBusy || self.currentlyRecording)];
        } else {
            [self.connectionLabel setText:@"Disconnected"];
            [self.capturePhotoButton setEnabled:NO];
            [self.captureVideoButton setEnabled:NO];
        }
        
        NSString *tuningStateString;
        switch(self.tuningState) {
            case FLIROneSDKTuningStateTuningSuggested:
                tuningStateString = @"Tuning Suggested";
                break;
            case FLIROneSDKTuningStateInProgress:
                tuningStateString = @"Tuning Progress";
                break;
            case FLIROneSDKTuningStateUnknown:
                tuningStateString = @"Tuning Unknown";
                break;
            case FLIROneSDKTuningStateTunedWithClosedShutter:
                tuningStateString = @"Tuned Closed";
                break;
            case FLIROneSDKTuningStateTunedWithOpenedShutter:
                tuningStateString = @"Tuned Open";
                break;
            case FLIROneSDKTuningStateTuningRequired:
                tuningStateString = @"Tuning Required";
                break;
            case FLIROneSDKTuningStateApproximatelyTunedWithOpenedShutter:
                tuningStateString = @"Tuned Approx.";
                break;
        }
        [self.tuningStateLabel setText:[NSString stringWithFormat:@"%@", tuningStateString]];
        
        [self.versionLabel setText:[[FLIROneSDK sharedInstance] version]];
        
        [self.batteryPercentageLabel setText:[NSString stringWithFormat:@"Battery: %ld%%", (long)self.batteryPercentage]];
        
        
        NSString *chargingState;
        switch(self.batteryChargingState) {
            case FLIROneSDKBatteryChargingStateCharging:
                chargingState = @"Yes";
                break;
            case FLIROneSDKBatteryChargingStateDischarging:
                chargingState = @"No";
                break;
                
            case FLIROneSDKBatteryChargingStateError:
                chargingState = @"Err";
                break;
            case FLIROneSDKBatteryChargingStateInvalid:
                chargingState = @"Invalid";
                break;
            default:
                chargingState = @"N/A";
                break;
        }
        [self.batteryChargingLabel setText:[NSString stringWithFormat:@"Charging: %@", chargingState]];
        
        
        if(self.currentlyRecording) {
            [self.captureVideoButton setTitle:@"Stop Video" forState:UIControlStateNormal];
        } else {
            [self.captureVideoButton setTitle:@"Start Video" forState:UIControlStateNormal];
        }
        
        [self.msxButton setTitle:[NSString stringWithFormat:@"MSX Distance: %@", (self.msxDistanceEnabled ? @"On" : @"Off")] forState:UIControlStateNormal];
        [self.emissivityButton setTitle:[NSString stringWithFormat:@"Emissivity: %0.2f", self.emissivity] forState:UIControlStateNormal];
        
        self.frameCountLabel.text = [NSString stringWithFormat:@"Count: %ld, %f", (long)self.frameCount, self.fps];
        
        //update the positions of the hottest, coldest, and temperature region views/labels
        //CGSize imageSize = self.radiometricImageView.frame.size;
        //CGPoint imageOrigin = self.radiometricImageView.frame.origin;
		//NEW USE THERMAL INSTEAD OF RADIOMETRIC
		CGSize imageSize = self.thermalImageView.frame.size;
		CGPoint imageOrigin = self.thermalImageView.frame.origin;
		
        if(self.pixelDataExists) {
            CGRect frame = CGRectZero;
            CGFloat size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width*self.pixelOfInterest.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height*self.pixelOfInterest.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.hottestPoint.frame = frame;
            frame.size.width = 100;
            self.hottestLabel.frame = frame;
            self.hottestLabel.text = [NSString stringWithFormat:@"%0.2fºK", self.pixelTemperature];
            
            frame = CGRectZero;
            size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width * self.coldPixel.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height * self.coldPixel.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.coldestPoint.frame = frame;
            frame.size.width = 100;
            self.coldestLabel.frame = frame;
            self.coldestLabel.text = [NSString stringWithFormat:@"%0.2fºK", self.coldestTemperature];
            
            
            ///upadting UI with locations of tileMarkers
            
            frame = CGRectZero;
            size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width * self.tilePixel2.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height * self.tilePixel2.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.tilePoint2.frame = frame;
            frame.size.width = 100;
            self.tileLabel2.frame = frame;
            self.tileLabel2.text = [NSString stringWithFormat:@"%0.2fºF", self.tileTemperature2 ];
            
            frame = CGRectZero;
            size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width * self.tilePixel5.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height * self.tilePixel5.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.tilePoint5.frame = frame;
            frame.size.width = 100;
            self.tileLabel5.frame = frame;
            self.tileLabel5.text = [NSString stringWithFormat:@"%0.2fºF", self.tileTemperature5 ];
            
            frame = CGRectZero;
            size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width * self.tilePixel8.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height * self.tilePixel8.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.tilePoint8.frame = frame;
            frame.size.width = 100;
            self.tileLabel8.frame = frame;
            self.tileLabel8.text = [NSString stringWithFormat:@"%0.3fºF", self.tileTemperature8 ];
            
            frame = CGRectZero;
            size = 30;
            frame.origin.x = imageOrigin.x + imageSize.width * self.tilePixel0.x - size/2.0;
            frame.origin.y = imageOrigin.y + imageSize.height * self.tilePixel0.y - size/2.0;
            frame.size.width = size;
            frame.size.height = size;
            self.tilePoint0.frame = frame;
            frame.size.width = 100;
            self.tileLabel0.frame = frame;
            self.tileLabel0.text = [NSString stringWithFormat:@"%0.2fºF", self.tileTemperature0 ];
            
            
        } else {
            self.hottestLabel.text = @"";
            self.hottestPoint.frame = CGRectZero;
            self.coldestLabel.frame = CGRectZero;
            self.coldestPoint.frame = CGRectZero;
            //setting them to 0
            
            self.tileLabel2.frame = CGRectZero;
            self.tilePoint2.frame = CGRectZero;
            self.tileLabel5.frame = CGRectZero;
            self.tilePoint5.frame = CGRectZero;
            self.tileLabel8.frame = CGRectZero;
            self.tilePoint8.frame = CGRectZero;
            self.tileLabel0.frame = CGRectZero;
            self.tilePoint0.frame = CGRectZero;
            
        }
		
		
		
    });
}

- (void) performTemperatureCalculations {
    uint16_t *tempData = (uint16_t *)[self.thermalData bytes];
    uint16_t temp = tempData[0];
    uint16_t hottestTemp = temp;
    uint16_t coldestTemp = temp;
	
    int index = 0;
    int coldIndex = 0;
	
   /* uint16_t minRegion = UINT16_MAX;
    int minRegionIndex = 0;
    uint16_t maxRegion = 0;
    int maxRegionIndex = 0;
    NSInteger regionCount = 0;
    NSInteger regionSum = 0;
	*/
    for(int i=0;i<self.thermalSize.width*self.thermalSize.height;i++) {
        temp = tempData[i];
        if(temp > hottestTemp) {
            hottestTemp = temp;
            index = i;
        }
        if(temp < coldestTemp) {
            coldestTemp = temp;
            coldIndex = i;
        }
	}
	/*
        CGFloat x = (i % (int)self.thermalSize.width)/self.thermalSize.width;
        CGFloat y = (i / self.thermalSize.width)/self.thermalSize.height;
		
        if(x > self.regionOfInterest.origin.x
           && x < self.regionOfInterest.origin.x + self.regionOfInterest.size.width
           && y > self.regionOfInterest.origin.y
           && y < self.regionOfInterest.origin.y + self.regionOfInterest.size.height) {
            regionCount += 1;
            regionSum += temp;
            if(temp > maxRegion) {
                maxRegion = temp;
                maxRegionIndex = i;
            }
            if(temp < minRegion) {
                minRegion = temp;
                minRegionIndex = i;
            }
		
        }
		
    }
		 
	
    uint16_t regionAverage = (regionSum/regionCount);
    
    self.regionMaxLabel.text = [NSString stringWithFormat:@"%0.2fºK", maxRegion/100.0];
    self.regionMinLabel.text = [NSString stringWithFormat:@"%0.2fºK", minRegion/100.0];
    self.regionAverageLabel.text = [NSString stringWithFormat:@"%0.2fºK", regionAverage/100.0];
    */
	
    NSInteger column = index % (int)self.thermalSize.width;
    NSInteger row = index / self.thermalSize.width;
    
    //update the thinger
    CGPoint location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
    //self.hottestPoint.frame = CGRectMake(
    self.pixelOfInterest = location;
    column = coldIndex % (int)self.thermalSize.width;
    row = coldIndex / self.thermalSize.width;
    
    location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
    self.coldPixel = location;
    
    self.coldestTemperature = coldestTemp/100.0;
    self.pixelTemperature = hottestTemp/100.0;

//---------------------------------------------------

//////////  checking for tempeartures
// all variables start at 1 , hence 2,5,8,0
// value of 0 depends on which mode we  are in

    
	double_t hottestTemperatureAtTile[12];
	uint16_t hottestTemperatureAtTileIndex[12];
	
	//To go from 0-11
	//0  1  2
	//3  4  5
	//6  7  8
	//9  10 11
	for(int i = 0; i < 12; i++)
	{
		hottestTemperatureAtTile[i] = 0;
		hottestTemperatureAtTileIndex[i] = 0;
	}
    
    NSInteger flirWidth  = 120;
    NSInteger flirHeight = 160;
    
    NSInteger tileNumbers = 12;
    NSInteger tileSize = flirWidth/3;
    
    NSInteger tilePositions[12];
    double_t tileTemperatures [tileNumbers];
    uint16_t tileHottestPoint [tileNumbers];
    
    
    for (int i = 0 ; i < tileNumbers; i++ )
    {
        tileTemperatures[i] = 0;
        tileHottestPoint[i] = 0;
    }
    /*
    for ( int i = 0 ; i< tileNumbers ; i++)
    {
        //wrong code
        
        tilePositions[i] = i * ( flirWidth* flirHeight)/tileNumbers;
        
        
    }
     */
    
    
    NSInteger w = -1 * ((tileSize - 1) * flirWidth);
    for(NSInteger i = 0; i < tileNumbers; i++)
        {
            
            if( i % 3 == 0 )
                w = w + ((tileSize - 1) * flirWidth);
            
            tilePositions[i] = (((i + 1) * tileSize) - tileSize) + w;
            //println("~~~~");
            //println( (((i + 1) * tileSize) - tileSize) + w);
            //calcTileTemp((((i + 1) * tileSize) - tileSize) + w);
        }
    
    
    
    for ( int t = 0 ; t< tileNumbers ; t++)
    {
        
        NSInteger startPoint = tilePositions[t];
        NSInteger hottestTemp = 0;
        NSInteger hottestIndex = 0;
        
        for( NSInteger i = 0 ; i< tileSize ; i ++)
        {
            for ( NSInteger j = 0 ; j< tileSize ; j ++)
            {
                NSInteger location = startPoint + i * 3 * tileSize  + j ;
                
                
                uint16_t localTemperature = tempData[ location ];  //unsure about the index positon
                
                if( localTemperature > hottestTemp )
                {
                    hottestTemp = localTemperature;
                    hottestIndex = location ;
                }
                
                
               
            }
        }
        
        tileTemperatures[t] = hottestTemp ;
        tileHottestPoint[t] = hottestIndex;
        
        
        
    }
    
    
    
    
    
    
    
		
    
		//Check Tile 5
		//Check Tile 8
		//Check Tile 9
		
		//NSString* myString = [@(hottestTemperatureAtTile[2]) stringValue];
		//self.debugLabel.text = myString;
        
        //converting temperatures to F from K so that it makes sense to me.
        
        for(int i = 0; i < 12; i++)
        {
            double_t tempK =  tileTemperatures[i] / 100.00;
            double_t tempF  = ( tempK  - 273.15 ) * 1.800 +32.00;
            
            tileTemperatures[i] = tempF ;

        }
        
        
        
		self.debugLabel.text = [NSString stringWithFormat:@"%0.2fºF", tileTemperatures[1]];
        
        
        ////pushing values for tile 2
        column = tileHottestPoint[1] % (int)self.thermalSize.width;
        row = tileHottestPoint[1] / self.thermalSize.width;
        location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
        self.tilePixel2 = location;
        self.tileTemperature2 = tileTemperatures[1];
    
        column = tileHottestPoint[4] % (int)self.thermalSize.width;
        row = tileHottestPoint[4] / self.thermalSize.width;
        location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
        self.tilePixel5 = location;
        self.tileTemperature5 = tileTemperatures[4];
    
        column = tileHottestPoint[7] % (int)self.thermalSize.width;
        row = tileHottestPoint[7] / self.thermalSize.width;
        location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
        self.tilePixel8 = location;
        self.tileTemperature8 = tileTemperatures[7];
    

    
        if([self.chosen_scan_mode isEqual: @"Scan Right Arm"])
            {
            column = tileHottestPoint[8] % (int)self.thermalSize.width;
            row = tileHottestPoint[8] / self.thermalSize.width;
            location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
            self.tilePixel0 = location;
            self.tileTemperature0 = tileTemperatures[8];
            }
    
        else if([self.chosen_scan_mode isEqual: @"Scan Left Arm"])

                {
                    column = tileHottestPoint[6] % (int)self.thermalSize.width;
                    row = tileHottestPoint[6] / self.thermalSize.width;
                    location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
                    self.tilePixel0 = location;
                    self.tileTemperature0 = tileTemperatures[6];
                }
    
        else if([self.chosen_scan_mode isEqual: @"Scan Left Leg"] || [self.chosen_scan_mode isEqual: @"Scan Right Leg"]  )
                {
                    column = tileHottestPoint[10] % (int)self.thermalSize.width;
                    row = tileHottestPoint[10] / self.thermalSize.width;
                    location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
                    self.tilePixel0 = location;
                    self.tileTemperature0 = tileTemperatures[10];
                }

    
        ////repeat the step above for 2,5,8,0
    
        
        
        
        /////////////////
//---------------------------------------
        
        
        
        

	
		
	
    
    
    
    
}

//events relating to user tapping the image views, switches formats on and off

//NEVER TOGETHER
//FLIROneSDKImageOptionsThermalRGBA8888Image
//FLIROneSDKImageOptionsBlendedMSXRGBA8888Image

//cycle between thermal, MSX, and none
- (IBAction)thermalButtonPressed:(id)sender {
	/*if( self.options &   FLIROneSDKImageOptionsThermalRGBA8888Image) {
		self.options &= ~FLIROneSDKImageOptionsThermalRGBA8888Image;
		
		self.options |=  FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
		self.options |=  FLIROneSDKImageOptionsThermalRadiometricKelvinImage; //ADDED THIS LINE
		
	} else*/
		if(//self.options & FLIROneSDKImageOptionsBlendedMSXRGBA8888Image &&
			self.options & FLIROneSDKImageOptionsThermalRGBA8888Image &&
			  self.options & FLIROneSDKImageOptionsThermalRadiometricKelvinImage &&
			  self.options & FLIROneSDKImageOptionsBlendedMSXRGBA8888Image) {
		//self.options &=  ~FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
		self.options &=  ~FLIROneSDKImageOptionsThermalRadiometricKelvinImage;
	} else {
		self.options |= FLIROneSDKImageOptionsThermalRGBA8888Image;
		self.options |= FLIROneSDKImageOptionsThermalRadiometricKelvinImage;
		self.options |= FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
	}
	
	[FLIROneSDKStreamManager sharedInstance].imageOptions = self.options;
	
	//PREVIOUS
/*    if( self.options &   FLIROneSDKImageOptionsThermalRGBA8888Image) {
        self.options &= ~FLIROneSDKImageOptionsThermalRGBA8888Image;
        self.options |=  FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
		//self.options |=  FLIROneSDKImageOptionsThermalRadiometricKelvinImage; //ADDED THIS LINE
    } else if(self.options & FLIROneSDKImageOptionsBlendedMSXRGBA8888Image) {
        self.options &=     ~FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
    } else {
        self.options |= FLIROneSDKImageOptionsThermalRGBA8888Image;
    }
	
    [FLIROneSDKStreamManager sharedInstance].imageOptions = self.options;*/
}
//cycle between 14 bit linear, radiometric, and none
/*- (IBAction)thermal14BitButtonPressed:(id)sender {
    if( self.options &   FLIROneSDKImageOptionsThermalLinearFlux14BitImage) {
        self.options &= ~FLIROneSDKImageOptionsThermalLinearFlux14BitImage;
        self.options |=  FLIROneSDKImageOptionsThermalRadiometricKelvinImage;
    } else if(self.options &  FLIROneSDKImageOptionsThermalRadiometricKelvinImage) {
        self.options &=      ~FLIROneSDKImageOptionsThermalRadiometricKelvinImage;
    } else {
        self.options |= FLIROneSDKImageOptionsThermalLinearFlux14BitImage;
    }
    
    [FLIROneSDKStreamManager sharedInstance].imageOptions = self.options;
}
*/

- (void) FLIROneSDKDidConnect {
    self.connected = YES;
    self.frameCount = 0;
    
    [self updateUI];
}

- (void) FLIROneSDKDidDisconnect {
    self.connected = NO;
    @synchronized([FLIROneSDKExampleViewController class]) {
        if(self.currentlyRecording) {
            [[FLIROneSDKStreamManager sharedInstance] stopRecordingVideo];
        }
    }
    [self updateUI];
}


//callbacks for image data delivered from sled
- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveFrameWithOptions:(FLIROneSDKImageOptions)options metadata:(FLIROneSDKImageMetadata *)metadata {
    self.options = options;
    self.emissivity = metadata.emissivity;
    self.palette = metadata.palette;
    
    if(!(self.options & FLIROneSDKImageOptionsBlendedMSXRGBA8888Image) && !(self.options & FLIROneSDKImageOptionsThermalRGBA8888Image)) {
        self.thermalImage = nil;
    }
	
	/*
    if(!(self.options & FLIROneSDKImageOptionsThermalLinearFlux14BitImage) && !(self.options & FLIROneSDKImageOptionsThermalRadiometricKelvinImage)) {
        self.radiometricImage = nil;
    }*/
    
    self.frameCount += 1;
    
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if(self.lastTime > 0) {
        self.fps = 1.0/(now - self.lastTime);
    }
    
    self.lastTime = now;
    
    [self updateUI];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveBlendedMSXRGBA8888Image:(NSData *)msxImage imageSize:(CGSize)size{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.thermalImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsBlendedMSXRGBA8888Image andData:msxImage andSize:size];
        [self updateUI];
    });
    
    //[self updateUI];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveThermalRGBA8888Image:(NSData *)thermalImage imageSize:(CGSize)size{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.thermalImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsThermalRGBA8888Image andData:thermalImage andSize:size];
        [self updateUI];
    });
    
    //[self updateUI];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveThermal14BitLinearFluxImage:(NSData *)linearFluxImage imageSize:(CGSize)size {
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.radiometricImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsThermalLinearFlux14BitImage andData:linearFluxImage andSize:size];
        [self updateUI];
    });
    */
    //[self updateUI];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveRadiometricData:(NSData *)radiometricData imageSize:(CGSize)size {
    
    @synchronized(self) {
        self.thermalData = radiometricData;
        self.thermalSize = size;
    }
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.radiometricImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsThermalRadiometricKelvinImage andData:radiometricData andSize:size];
        [self updateUI];
    });*/
    
    //[self updateUI];
}


//callbacks relating to capturing images to library
- (void) FLIROneSDKDidFinishCapturingPhoto:(FLIROneSDKCaptureStatus)captureStatus withFilepath:(NSURL *)filepath {
    self.cameraBusy = NO;
    [self updateUI];
}

//tuning callback
- (void) FLIROneSDKTuningStateDidChange:(FLIROneSDKTuningState)newTuningState {
    self.tuningState = newTuningState;
    [self updateUI];
}

//charging callback
- (void) FLIROneSDKBatteryChargingStateDidChange:(FLIROneSDKBatteryChargingState)state {
    self.batteryChargingState = state;
    [self updateUI];
}

//battery callback
- (void) FLIROneSDKBatteryPercentageDidChange:(NSNumber *)percentage {
    self.batteryPercentage = [percentage integerValue];
    [self updateUI];
}

//enable or disable MSX
- (IBAction) msxButtonPressed:(UIButton *)button {
    self.msxDistanceEnabled = !self.msxDistanceEnabled;
    
    [FLIROneSDKStreamManager sharedInstance].msxDistanceEnabled = YES;
    [FLIROneSDKStreamManager sharedInstance].msxDistance = self.msxDistanceEnabled ? 0 : 1;
    
}

//switch emissivity value to one of 5 values
- (IBAction) emissivityPressed:(UIButton *)button {
    CGFloat customValue = 0.5;
    
    if(fabs(self.emissivity - FLIROneSDKEmissivityGlossy) < 0.01) {
        self.emissivity = FLIROneSDKEmissivitySemiGlossy;
    } else if(fabs(self.emissivity - FLIROneSDKEmissivitySemiGlossy) < 0.01) {
        self.emissivity = FLIROneSDKEmissivitySemiMatte;
    } else if(fabs(self.emissivity - FLIROneSDKEmissivitySemiMatte) < 0.01) {
        self.emissivity = FLIROneSDKEmissivityMatte;
    } else if(fabs(self.emissivity - FLIROneSDKEmissivityMatte) < 0.01) {
        self.emissivity = customValue;
    } else if(fabs(self.emissivity - customValue) < 0.01) {
        self.emissivity = FLIROneSDKEmissivityGlossy;
    } else {
        self.emissivity = customValue;
    }
    [[FLIROneSDKStreamManager sharedInstance] setEmissivity:self.emissivity];
}

- (IBAction)viewLibrary:(id)sender {
    [FLIROneSDKLibraryViewController presentLibraryFromViewController:self];
}

- (IBAction)capturePhoto:(id)sender {
    self.cameraBusy = YES;
    [self updateUI];
    
    
    NSURL *filepath = [[FLIROneSDKLibraryManager sharedInstance] libraryFilepathForCurrentTimestampWithExtension:@"png"];
    
    [[FLIROneSDKStreamManager sharedInstance] capturePhotoWithFilepath:filepath];
}

- (IBAction) captureVideo:(id)sender {
    @synchronized([FLIROneSDKExampleViewController class]) {
        self.cameraBusy = YES;
        if(self.currentlyRecording) {
            //stop recording
            [[FLIROneSDKStreamManager sharedInstance] stopRecordingVideo];
        } else {
            NSURL *filepath = [[FLIROneSDKLibraryManager sharedInstance] libraryFilepathForCurrentTimestampWithExtension:@"mov"];
            [[FLIROneSDKStreamManager sharedInstance] startRecordingVideoWithFilepath:filepath withVideoRendererDelegate:self];
        }
        
        [self updateUI];
    }
}

//callbacks for video recording
- (void) FLIROneSDKDidStartRecordingVideo:(FLIROneSDKCaptureStatus)captureStartStatus {
    if(captureStartStatus == FLIROneSDKCaptureStatusSucceeded) {
        self.currentlyRecording = YES;
    } else {
        self.cameraBusy = NO;
    }
    
    [self updateUI];
}

- (void) FLIROneSDKDidStopRecordingVideo:(FLIROneSDKCaptureStatus)captureStopStatus {
    self.currentlyRecording = NO;
    
    if(captureStopStatus == FLIROneSDKCaptureStatusFailedWithUnknownError) {
        self.cameraBusy = NO;
    }
    
    [self updateUI];
}

- (void) FLIROneSDKDidFinishWritingVideo:(FLIROneSDKCaptureStatus)captureWriteStatus withFilepath:(NSString *)videoFilepath {
    
    self.cameraBusy = NO;
    
    [self updateUI];
}

//grab any valid image delivered from the sled
- (UIImage *)currentImage {
//    UIImage *image = self.radiometricImage;
	UIImage *image = self.thermalImage;

    /*if(!image) {
        image = self.radiometricImage;
    }*/
    if(!image) {
        image = self.thermalImage;
    }

    return image;
}

//callback for rendering video in arbitrary video format
- (UIImage *)imageForFrameAtTimestamp:(CMTime)timestamp {
    NSLog(@"size: %@", NSStringFromCGSize(self.currentImage.size));
    NSLog(@"%d, %lld", timestamp.timescale, timestamp.value);
    NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
    NSLog(@"uptime: %f", uptime);
    return [self currentImage];
}

@end
