//
//  avlib.c
//  TakeMeBack
//
//  Created by Jim Billmeyer on 2/22/13.
//  Copyright (c) 2013 SoftSolutions, Inc. All rights reserved.
//

#include <stdio.h>
#include "avlib.h"
#include "math.h"


static const double PI = 3.14159265358979323846;


double radians(double dpAngle)
{
   return dpAngle * PI / 180.0;
}


double degrees(double dpAngle)
{
   return dpAngle * 180.0 /  PI;
}


double nauticalMilesToMiles(double dpNMiles)
{
   return dpNMiles * 1.150779;
}


AvCoord AvCoordMake(double dpLat, double dpLon)
{
   AvCoord coord;
   
   coord.dpLat = dpLat;
   coord.dpLon = dpLon;
   
   return coord;
}


// ============================================================================
// The function is documented in the header file.
// ============================================================================

double avGetDistanceBetween(AvCoord pt1, AvCoord pt2)
{
   double dpDist;
   
   pt1.dpLat = radians(pt1.dpLat);
   pt1.dpLon = radians(pt1.dpLon);
   pt2.dpLat = radians(pt2.dpLat);
   pt2.dpLon = radians(pt2.dpLon);
   
   double dpSinLat = sin((pt1.dpLat - pt2.dpLat) / 2.0);
   double dpSinLon = sin((pt1.dpLon - pt2.dpLon) / 2.0);
   
   dpDist = dpSinLat * dpSinLat + cos(pt1.dpLat) * cos(pt2.dpLat) * dpSinLon * dpSinLon;
   dpDist = sqrt(dpDist);
   dpDist = 2 * degrees(asin(dpDist));
   
   // ---------------------------------------------
   // convert from distance degrees to distance nm.
   // ---------------------------------------------
   
   dpDist = dpDist * 60.0;
   return dpDist;
}


// ============================================================================
// The function is documented in the header file.
// ============================================================================

double avGetCourse(AvCoord pt1, AvCoord pt2)
{
   double dpLat1, dpLon1, dpLat2, dpLon2;
   
   if (fabs(pt1.dpLat) > 89.99)
   {
      if (pt1.dpLat > 0)
      {
         dpLat1 = PI;
      }
      else
      {
         dpLat1 = 2.0f * PI;
      }
   }
   else
   {
      dpLat1 = radians(pt1.dpLat);
   }
   
   dpLon1 = radians(pt1.dpLon);
   dpLat2 = radians(pt2.dpLat);
   dpLon2 = radians(pt2.dpLon);
   
   double dpCosPt2Lat = cos(dpLat2);
   
   return degrees(atan2(sin(dpLon1 - dpLon2) * dpCosPt2Lat,
                        cos(dpLat1) * sin(dpLat2) - sin(dpLat1) * dpCosPt2Lat * cos(dpLon1 - dpLon2)));
}


// ============================================================================
// The function is documented in the header file.
// ============================================================================

double avGetCourseCompass(AvCoord pt1, AvCoord pt2)
{
   double dpCourse = avGetCourse(pt1, pt2);
   dpCourse = dpCourse < 0 ? dpCourse * -1 : 360 - dpCourse;
   
   return dpCourse;
}
