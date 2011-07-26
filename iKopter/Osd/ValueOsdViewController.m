// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
//
// See License.txt for complete licensing and attribution information.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ///////////////////////////////////////////////////////////////////////////////


#import "ValueOsdViewController.h"
#import "UIImage+Tint.h"
#import "UIColor+ColorWithHex.h"

/////////////////////////////////////////////////////////////////////////////////
@interface ValueOsdViewController()

- (void) updateViewWithOrientation: (UIInterfaceOrientation) orientation;
- (void) hideInfoViewAnimated;
- (void) hideInfoView:(BOOL)animated;
- (void) showInfoView;

@end

/////////////////////////////////////////////////////////////////////////////////
@implementation ValueOsdViewController

@synthesize batteryIcon;
@synthesize targetIcon;
@synthesize variometer;
@synthesize gpsSateliteOk;
@synthesize gpsSateliteErr;
@synthesize heigth;
@synthesize heigthSetpoint;
@synthesize battery;
@synthesize current;
@synthesize usedCapacity;
@synthesize satelites;
@synthesize gpsSatelite;
@synthesize gpsMode;
@synthesize gpsTarget;
@synthesize flightTime;
@synthesize compass;
@synthesize attitude;
@synthesize speed;
@synthesize waypoint;
@synthesize targetPosDev;
@synthesize homePosDev;
@synthesize noData;
@synthesize altitudeControl;
@synthesize careFree;
@synthesize targetReached;
@synthesize targetReachedPending;
@synthesize batteryOk;
@synthesize batteryLow;
@synthesize infoView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      gpsOkColor=[[UIColor colorWithRed:0.0 green:0.5 blue:0.25 alpha:1.0]retain];
      functionOffColor=[[UIColor colorWithHexString:@"#E6E6E6" andAlpha:1.0]retain];
      functionOnColor=[UIColor blueColor];

      self.gpsSateliteOk = [UIImage imageNamed:@"gpsSat2.png"];
      self.gpsSateliteErr=[self.gpsSateliteOk imageTintedWithColor:[UIColor redColor]];
      
      self.targetReachedPending = [UIImage imageNamed:@"13-target.png"];
      self.targetReached=[self.targetReachedPending imageTintedWithColor:gpsOkColor];
     
      self.batteryOk = [UIImage imageNamed:@"battery.png"];
      self.batteryLow=[self.batteryOk imageTintedWithColor:[UIColor redColor]];
      
    }
    return self;
}


- (void)dealloc {
  [gpsOkColor release];
  gpsOkColor=nil;
  [functionOffColor release];
  functionOffColor=nil;
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];


}

- (void)viewDidUnload
{
  [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateViewWithOrientation:[UIApplication sharedApplication].statusBarOrientation];

  [self hideInfoViewAnimated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void) updateViewWithOrientation: (UIInterfaceOrientation) orientation  {
  
  
  if ( UIInterfaceOrientationIsPortrait(orientation) ){
    [[NSBundle mainBundle] loadNibNamed:@"ValueOsdViewController" owner:self options:nil];
  }
  else if (UIInterfaceOrientationIsLandscape(orientation)){
    [[NSBundle mainBundle] loadNibNamed:@"ValueOsdViewControllerLandscape" owner:self options:nil];
  }

  self.altitudeControl.badgeInsetColor=functionOffColor;
  [self.altitudeControl autoBadgeSizeWithString:@"ALT"];
  
  self.careFree.badgeInsetColor=functionOffColor;
  [self.careFree autoBadgeSizeWithString:@"ALT"];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
  [self updateViewWithOrientation: orientation];

}

/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Navigation bar Hideing 

- (void)showInfoView{

  CGRect frame = infoView.bounds;

  frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height - frame.size.height;

  self.infoView.hidden=NO;
  
  [UIView animateWithDuration:0.75
                     animations:^ {
                       self.infoView.frame = frame;
                     }];


  
  
}

- (void)hideInfoView:(BOOL)animated{

  CGRect frame = infoView.bounds;
  frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
  
  if(!animated){
    infoView.frame = frame;
    infoView.hidden=YES;
  }
  else{
    [UIView animateWithDuration:0.75
                     animations:^ {
                       self.infoView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                       infoView.hidden=YES;
                     }];
  }
}

- (void)hideInfoViewAnimated{
  [self hideInfoView:YES];
}

- (void)hideInfoViewAfterDelay:(NSTimeInterval)delay
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInfoViewAnimated) object:nil];
  qltrace(@"Calling performSelector with delay %f",delay);
  [self performSelector:@selector(hideInfoViewAnimated) withObject:nil afterDelay:delay];
}

#pragma mark OsdValueDelegate implementation
- (void) newValue:(OsdValue*)value {
  
  self.noData.hidden=YES;
  
  IKMkNaviData*data=value.data.data;
  
  if (data->Errorcode>0 && self.infoView.hidden) {
    infoView.text = [NSString stringWithFormat:NSLocalizedString(@"Error: %d", @"OSD NC error"),data->Errorcode];
    [self showInfoView];
  }
  else if(data->Errorcode==0 && !self.infoView.hidden) {
    [self hideInfoViewAnimated];
  }
    
  if(data->Variometer==0)
    variometer.text=@"";
  else
    variometer.text=data->Variometer<0?@"▾":@"▴";
    
  
  heigth.text=[NSString stringWithFormat:@"%0.1f m",data->Altimeter/20.0];  
  heigthSetpoint.text=[NSString stringWithFormat:@"%0.1f",data->SetpointAltitude/20.0];  
  
  battery.text=[NSString stringWithFormat:@"%0.1f V ",data->UBat/10.0];    
  
  battery.backgroundColor=value.isLowBat?[UIColor redColor]:[UIColor clearColor];
  battery.textColor=value.isLowBat?[UIColor whiteColor]:[UIColor blackColor];
  
  current.text=[NSString stringWithFormat:@"%0.1f",data->Current/10.0];      
  usedCapacity.text=[NSString stringWithFormat:@"%d",data->UsedCapacity];  
  
  satelites.badgeInsetColor = value.isGpsOk?gpsOkColor:[UIColor redColor];
  [satelites autoBadgeSizeWithString:[NSString stringWithFormat:@"%d",data->SatsInUse]];
  
  self.altitudeControl.badgeInsetColor=value.isAltControlOn?functionOnColor:functionOffColor;
  self.altitudeControl.badgeText=@"Alt";
  [self.altitudeControl setNeedsDisplay];
  
  self.careFree.badgeInsetColor=value.isCareFreeOn?functionOnColor:functionOffColor;
  self.careFree.badgeText=@"CF";
  [self.careFree setNeedsDisplay];
  
  
  attitude.text=[NSString stringWithFormat:@"%d° / %d° / %d°",data->CompassHeading,
                 data->AngleNick,
                 data->AngleRoll];
  speed.text=[NSString stringWithFormat:@"%d km/h",(data->GroundSpeed*9)/250];
  
  waypoint.text=[NSString stringWithFormat:@"%d / %d (%d)",data->WaypointIndex,data->WaypointNumber,value.poiIndex];
  
  NSUInteger headingHome = (data->HomePositionDeviation.Bearing + 360 - data->CompassHeading) % 360;
  homePosDev.text=[NSString stringWithFormat:@"%d° / %d m",headingHome,data->HomePositionDeviation.Distance / 10];
  
  NSUInteger headingTarget = (data->TargetPositionDeviation.Bearing + 360 - data->CompassHeading) % 360;
  if(value.isTargetReached && data->TargetHoldTime>0)
    targetPosDev.text=[NSString stringWithFormat:@"%d° / %d m (%d s)",headingTarget,data->TargetPositionDeviation.Distance / 10,data->TargetHoldTime];
  else
    targetPosDev.text=[NSString stringWithFormat:@"%d° / %d m",headingTarget,data->TargetPositionDeviation.Distance / 10];

  compass.heading=data->CompassHeading;
  compass.homeDeviation=headingHome;
  compass.targetDeviation=headingTarget;
 
  gpsSatelite.image= value.isGpsOk?gpsSateliteOk:gpsSateliteErr;
  
  targetIcon.image = value.isTargetReached?targetReached:targetReachedPending;
  
  batteryIcon.image = value.isLowBat?batteryLow:batteryOk;
 
  if(value.isFreeModeEnabled)
    gpsMode.text=@"Free";    
  else if(value.isPositionHoldEnabled)
    gpsMode.text=@"Pos. Hold";    
  else if(value.isComingHomeEnabled)
    gpsMode.text=@"Coming Home";    
  else
    gpsMode.text=@"??";    
  
  flightTime.text=[NSString stringWithFormat:@"%02d:%02d",data->FlyingTime/60,data->FlyingTime%60];
  
//  if(value.isTargetReached)
//    gpsTarget.text=@"TARGET";
//  else
//    gpsTarget.text=@"";
}  

- (void) noDataAvailable {
  self.noData.hidden=NO;
}

@end
