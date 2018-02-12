//
//  avlib.h
//  TakeMeBack
//
//  Created by Jim Billmeyer on 2/22/13.
//  Copyright (c) 2013 SoftSolutions, Inc. All rights reserved.
//

#ifndef TakeMeBack_avlib_h
#define TakeMeBack_avlib_h

typedef struct
{
   double dpLat;
   double dpLon;
} AvCoord, *AvCoordPtr;


/**
 * helper function to populate a coordinate.
 */
AvCoord AvCoordMake(double dpLat, double dpLon);


double nauticalMilesToMiles(double dpNMiles);


double radians(double dpAngle);


double degrees(double dpAngle);


/**
 * Calculates the great circle distance between two points.
 *
 * @param pt1 - the first lat/long coordinate.
 * @param pt2 - the second lat/long coordinate.
 *
 * @return The distance between two points in nmiles.
 */

double avGetDistanceBetween(AvCoord pt1, AvCoord pt2);


/**
 * Calculates the course defined by two points. Neg results cw, Pos results ccw.
 *
 * @param[in] pt1 The first lat/long coordinate.
 * @param[in] pt2 The second lat/long coordinate.
 *
 * @return The course between the two coordinates in degrees.
 */

double avGetCourse(AvCoord pt1, AvCoord pt2);


/**
 * Calculates the course defined by two points.
 *
 * @param[in] pt1 The first lat/long coordinate.
 * @param[in] pt2 - the second lat/long coordinate.
 *
 * @return The course between the two coordinates between 0-359 degrees.
 */

double avGetCourseCompass(AvCoord pt1, AvCoord pt2);


#endif
