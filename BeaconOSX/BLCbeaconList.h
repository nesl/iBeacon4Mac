//
//  BLCbeaconList.h
//  BeaconOSX
//
//  Created by Bo Jhang Ho on 3/14/14.
//  Copyright (c) 2014 Blended Cocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCbeaconList : NSObject

- (void)inputTime:(double)timestamp uuid:(NSString*)uuid major:(NSInteger)major minor:(NSInteger)minor power:(double)power rssi:(double)rssi;
- (NSString*)getText;
- (BOOL)isEmpty;

@end
