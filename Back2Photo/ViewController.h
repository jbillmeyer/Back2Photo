//
//  ViewController.h
//  TakeMeBack
//
//  Created by Jim Billmeyer on 2/21/13.
//  Copyright (c) 2013 SoftSolutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AlbumViewController.h"
#import "avlib.h"


@interface ViewController : UIViewController <CLLocationManagerDelegate>
{
   AlbumViewController *viewAlbum;
   
   NSNumberFormatter *fmtNumber;

   AvCoord coordPhoto;
   AvCoord coord;
   
   bool fValidLocation;
   bool fMessageDisplayed;
   
   double dpDist;
   double dpHeadingMag;
   double dpCourse;
   
   double dpHorizontalAccuracy;
   double dpVerticalAccuracy;
   double dpHeadingAccuracy;
   
   long lHeadingAccAcount;
   
   bool fMetric;
   
   UIColor *colorGreen;
   UIColor *colorYellow;
   UIColor *colorRed;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet UIImageView *imageBackground;
@property (nonatomic, retain) IBOutlet UIImageView *imageOverlay;
@property (nonatomic, retain) IBOutlet UIImageView *imageDirection;
@property (nonatomic, retain) IBOutlet UIImageView *imagePhoto;
@property (nonatomic, retain) IBOutlet UILabel     *txtDistance;
@property (nonatomic, retain) IBOutlet UILabel     *txtDistanceMsg;
@property (nonatomic, retain) IBOutlet UILabel     *txtGPSMsg;
@property (nonatomic, retain) IBOutlet UILabel     *txtMagnetometerMsg;
@property (nonatomic, retain) IBOutlet UIButton    *btnPhoto;
@property (nonatomic, retain) IBOutlet UIButton    *btnDistance;

@end
