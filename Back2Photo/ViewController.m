//
//  ViewController.m
//  TakeMeBack
//
//  Created by Jim Billmeyer on 2/21/13.
//  Copyright (c) 2013 SoftSolutions, Inc. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface ViewController ()

@end

@implementation ViewController

@synthesize locationManager = _locationManager;

@synthesize imageBackground;
@synthesize imageOverlay;
@synthesize imageDirection;
@synthesize imagePhoto;
@synthesize txtDistance;
@synthesize txtDistanceMsg;
@synthesize txtGPSMsg;
@synthesize txtMagnetometerMsg;
@synthesize btnPhoto;
@synthesize btnDistance;


- (void) viewDidLoad
{
   [super viewDidLoad];

   float fpHeight = [[UIScreen mainScreen] bounds].size.height;
   
   if (fpHeight == 480)
   {
      imageOverlay.image = [UIImage imageNamed: @"overlay.png"];
   }
   
   txtDistance.layer.shadowOpacity = 1.0;
   txtDistance.layer.shadowRadius  = 3.0;
   txtDistance.layer.shadowColor   = [UIColor blackColor].CGColor;
   txtDistance.layer.shadowOffset  = CGSizeMake(3.0, 3.0);
   txtDistance.layer.masksToBounds = NO;
   
   txtDistanceMsg.alpha     = 0.0f;
   txtGPSMsg.alpha          = 0.0f;
   txtMagnetometerMsg.alpha = 0.0f;

   colorGreen  = [[UIColor alloc] initWithRed: 0.4f green: 1.0f blue: 0.4f alpha: 1.0f];
   colorYellow = [[UIColor alloc] initWithRed: 1.0f green: 1.0f blue: 0.4f alpha: 1.0f];
   colorRed    = [[UIColor alloc] initWithRed: 1.0f green: 0.4f blue: 0.4f alpha: 1.0f];
   
   _locationManager = [[CLLocationManager alloc] init];
   
   _locationManager.delegate        = self;
   _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
   _locationManager.distanceFilter  = 0;
   self.locationManager             = _locationManager;
   
   fmtNumber = [[NSNumberFormatter alloc] init];
   [fmtNumber setNumberStyle:NSNumberFormatterDecimalStyle];
   [fmtNumber setMaximumFractionDigits: 0];
   [fmtNumber setMinimumFractionDigits: 0];

   if (fpHeight == 1024)
   {
      imageDirection = [[UIImageView alloc] initWithFrame: CGRectMake(43.0f, 880.0f,
                                                                      imageDirection.bounds.size.width,
                                                                      imageDirection.bounds.size.height)];
      imageDirection.image = [UIImage imageNamed: @"arrow_iPad.png"];
   }
   else
   {
      imageDirection = [[UIImageView alloc] initWithFrame: CGRectMake(11.0f, 388.0f,
                                                                      imageDirection.bounds.size.width,
                                                                      imageDirection.bounds.size.height)];
      imageDirection.image = [UIImage imageNamed: @"arrow.png"];
   }
   [self.view addSubview: imageDirection];
   
   NSLocale *locale = [NSLocale currentLocale];
   fMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
   
   fValidLocation = NO;
}


- (void) viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   float fpHeight = [[UIScreen mainScreen] bounds].size.height;
   
   if (fpHeight == 480)
   {
      CGPoint pt = imageBackground.center;
      
      imageBackground.center = CGPointMake(pt.x, pt.y - 88.0f);
      btnPhoto.center   = CGPointMake(pt.x, pt.y - 88.0f);
      btnPhoto.bounds   = CGRectMake(0.0f, 0.0f, 320.0f, 360.0f);
      imagePhoto.center = CGPointMake(pt.x, pt.y - 88.0f);
      imagePhoto.bounds = CGRectMake(0.0f, 0.0f, 320.0f, 360.0f);
   }
   else if (fpHeight == 568)
   {
      CGPoint pt = imageDirection.center;
      imageDirection.center = CGPointMake(pt.x, pt.y + 88);
   }
}


- (void) viewWillAppear: (BOOL) animated
{
   [super viewWillAppear: animated];
   
   [[NSNotificationCenter defaultCenter] addObserver: self
                                            selector: @selector(receivePhotoNotification:)
                                                name: @"PhotoNotification"
                                              object: nil];
}


- (void) viewWillDisappear: (BOOL) animated
{
   [super viewWillDisappear: animated];
}


- (void) didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}


- (IBAction) btnPressedPhoto: (id) sender
{
   fMessageDisplayed = NO;
   
   viewAlbum = [[AlbumViewController alloc] initWithNibName: @"AlbumViewController"
                                                    bundle: [NSBundle mainBundle]];
   viewAlbum.delegate = self;
   UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: viewAlbum];
   [self presentViewController: nav animated: YES completion: nil];
}


- (IBAction) btnPressedDistance: (id) sender
{
   if (txtDistance.alpha == 1.00)
   {
      fMetric ^= YES;
      
      [self updateDistance];
   }
   else
   {
      UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"GPS Accuracy"
                                                        message:@"The GPS is still getting its fix. Make sure you have a clear view of the sky."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
      [message show];
   }
}


- (void) receivePhotoNotification: (NSNotification *) notification
{
   ALAsset *asset = notification.object;
   
   if (asset != nil)
   {
      CLLocation *location = [asset valueForProperty: ALAssetPropertyLocation];
      
      if ((fValidLocation = location != nil))
      {
         coordPhoto = AvCoordMake(location.coordinate.latitude, location.coordinate.longitude);
      }
      else if (fMessageDisplayed == NO)
      {
         fMessageDisplayed = YES;
         
         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Photo Location Error!"
                                                           message:@"The location information in the photo is missing. The privacy location services for photos needs to be turned on to work with Back2Photo."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
         [message show];
      }

      ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
      
      UIImage *image = [UIImage imageWithCGImage: [assetRepresentation fullScreenImage]
                                           scale: [assetRepresentation scale]
                                     orientation: (UIImageOrientation) ALAssetOrientationUp];
      
      // ----------------------------
      // scale the image to best fit.
      // ----------------------------
      
      CGSize sizePhoto = image.size;
      CGSize sizeView  = imagePhoto.bounds.size;
      float  fpScale;
      
      if (abs(sizePhoto.width - sizeView.width) < abs(sizePhoto.height - sizeView.height))
      {
         fpScale = sizeView.width / sizePhoto.width;
      }
      else
      {
         fpScale = sizeView.height / sizePhoto.height;
      }
      
      CGRect bounds = CGRectMake(0.0f, 0.0f, sizePhoto.width * fpScale, sizePhoto.height * fpScale);
      
      UIGraphicsBeginImageContext(bounds.size);
      [image drawInRect: bounds];
      image = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      // ---------------
      // crop the photo.
      // ---------------
      
      sizePhoto = image.size;
      
      CGRect rectCrop = CGRectMake((sizePhoto.width - sizeView.width) / 2.0f,
                                   (sizePhoto.height - sizeView.height) / 2.0f,
                                   sizeView.width,
                                   sizeView.height);
      
      CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rectCrop);
      image = [UIImage imageWithCGImage:imageRef];
      CGImageRelease(imageRef);
      
      // -------------
      // render image.
      // -------------
      
      imagePhoto.image = image;
      
      // ------------------------------
      // start gps and heading updates.
      // ------------------------------
      
      [self.locationManager startUpdatingLocation];
      [self.locationManager startUpdatingHeading];
      
      txtGPSMsg.alpha          = 1.0f;
      txtMagnetometerMsg.alpha = 1.0f;
      
   }
   else
   {
      [self.locationManager stopUpdatingLocation];
      [self.locationManager stopUpdatingHeading];

      txtGPSMsg.alpha          = 0.0f;
      txtMagnetometerMsg.alpha = 0.0f;
   }
}


- (void) updateDistance
{
   if (!fValidLocation)
   {
      return;
   }
   
   if (fMetric)
   {
      if (dpDist < 1.0)
      {
         txtDistance.text = [NSString stringWithFormat: @"%@ meters", [fmtNumber stringFromNumber: [NSNumber numberWithDouble: dpDist * 1000.0 * 1.60934]]];
      }
      else
      {
         txtDistance.text = [NSString stringWithFormat: @"%@ kmeters", [fmtNumber stringFromNumber: [NSNumber numberWithDouble: dpDist * 1.60934]]];
      }
   }
   else
   {
      if (dpDist < 1.0)
      {
         txtDistance.text = [NSString stringWithFormat: @"%@ feet", [fmtNumber stringFromNumber: [NSNumber numberWithDouble: dpDist * 5280.0]]];
      }
      else
      {
         txtDistance.text = [NSString stringWithFormat: @"%@ miles", [fmtNumber stringFromNumber: [NSNumber numberWithDouble: dpDist]]];
      }
   }
   
   if ((dpDist * 1000.0 * 1.60934 * 2.0) < dpHorizontalAccuracy || (dpDist * 5280.0) < 50.0)
   {
      txtDistanceMsg.alpha = 1.0f;
   }
   else
   {
      txtDistanceMsg.alpha = 0.0f;
   }
}


/**
 * Handles the location manager location update event.
 */
-(void) locationManager: (CLLocationManager *) manager
    didUpdateToLocation: (CLLocation *) newLocation
           fromLocation: (CLLocation *) oldLocation
{
   coord = AvCoordMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
   
   dpHorizontalAccuracy = newLocation.horizontalAccuracy;
   dpVerticalAccuracy   = newLocation.verticalAccuracy;
   
   if (dpHorizontalAccuracy > 0)
   {
      dpDist = avGetDistanceBetween(coord, coordPhoto);
      dpDist = nauticalMilesToMiles(dpDist);
      dpCourse = avGetCourseCompass(coord, coordPhoto);
      
      [self updateDistance];
      
      txtDistance.alpha = 1.0;
   }
   else
   {
      txtDistance.alpha = 0.25;
   }
   
   if (dpHorizontalAccuracy < 0.0)
   {
      txtGPSMsg.textColor = colorRed;
   }
   else if (dpHorizontalAccuracy < 15.0)
   {
      txtGPSMsg.textColor = colorGreen;
   }
   else
   {
      txtGPSMsg.textColor = colorYellow;
   }
}


/**
 * Handles the location manager heading update event.
 */
- (void)locationManager: (CLLocationManager *) manager didUpdateHeading: (CLHeading *) newHeading
{
   dpHeadingMag = [newHeading magneticHeading];
   
   dpHeadingAccuracy = [newHeading headingAccuracy];
   
   if (dpHeadingAccuracy > 0 && fValidLocation)
   {
      double dpDir = 360.0 - (dpHeadingMag - dpCourse + 90.0);
      imageDirection.transform = CGAffineTransformMakeRotation(radians(dpDir));
      imageDirection.alpha = 1.0;
      
      lHeadingAccAcount = 0;
   }
   else
   {
      imageDirection.alpha = 0.25;
      
      if (lHeadingAccAcount == 10)
      {
         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Heading Error!"
                                                           message:@"The heading is not locking in. Try moving your device around a little to help it lock in."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
         [message show];
         
         lHeadingAccAcount = 11;
      }
      else
      {
         [NSThread sleepForTimeInterval: 0.25];
         lHeadingAccAcount++;
      }
   }
   
   if (dpHeadingAccuracy < 0.0)
   {
      txtMagnetometerMsg.textColor = colorRed;
   }
   else if (dpHeadingAccuracy < 2.0)
   {
      txtMagnetometerMsg.textColor = colorGreen;
   }
   else
   {
      txtMagnetometerMsg.textColor = colorYellow;
   }
}

@end
