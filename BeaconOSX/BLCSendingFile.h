//
//  BLCSendingFile.h
//  BeaconOSX
//
//  Created by Bo Jhang Ho on 3/17/14.
//  Copyright (c) 2014 Blended Cocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLCAppDelegate.h"

@interface BLCSendingFile : NSObject {

}

- (id)initWithIp:(const char*)_ip port:(int)_port;
- (void)setReceiver:(BLCAppDelegate*)receiver;
- (void)setMyInfoUUID:(const char *)uuid myMajor:(int)major myMinor:(int)minor myPower:(double)power;
- (void)updateIp:(const char*)_ip port:(int)_port;
- (void)insertUUID:(const char *)uuid major:(int)major minor:(int)minor power:(double)power rssi:(double)rssi timestamp:(double)timestamp;
- (void)upload;

@end
