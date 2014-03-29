//
//  BLCbeaconList.m
//  BeaconOSX
//
//  Created by Bo Jhang Ho on 3/14/14.
//  Copyright (c) 2014 Blended Cocoa. All rights reserved.
//

#import "BLCbeaconList.h"

@interface BLCbeaconList () {
    NSString *suuid[100];
    NSInteger smajor[100];
    NSInteger sminor[100];
    double spower[100];
    double srssi[100];
    double stimestamp[100];
    int nrOfRecord;
}

@end

@implementation BLCbeaconList

- (void)update {
    double nowTime = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < nrOfRecord; i++) {
        if (nowTime - stimestamp[i] > 60.0) {
            for (int j = i; j < nrOfRecord - 2; j++) {
                suuid[j] = suuid[j+1];
                smajor[j] = smajor[j+1];
                sminor[j] = sminor[j+1];
                spower[j] = spower[j+1];
                srssi[j] = srssi[j+1];
                stimestamp[j] = stimestamp[j+1];
            }
            nrOfRecord--;
            i--;
        }
    }
}

- (void)inputTime:(double)timestamp uuid:(NSString*)uuid major:(NSInteger)major minor:(NSInteger)minor power:(double)power rssi:(double)rssi {
    [self update];
    for (int i = 0; i < nrOfRecord; i++) {
        if ([uuid isEqualToString:suuid[i]] && major == smajor[i] && minor == sminor[i]) {
            spower[i] = power;
            srssi[i] = rssi;
            stimestamp[i] = timestamp;
            return;
        }
    }
    if (nrOfRecord < 100) {
        suuid[nrOfRecord] = uuid;
        smajor[nrOfRecord] = major;
        sminor[nrOfRecord] = minor;
        spower[nrOfRecord] = power;
        srssi[nrOfRecord] = rssi;
        stimestamp[nrOfRecord] = timestamp;
        nrOfRecord++;
    }
}

- (NSString*)getText {
    [self update];

    if (nrOfRecord == 0)
        return @"(detecting...)";
    
    double nowTime = CFAbsoluteTimeGetCurrent();

    NSString *re = @"";
    for (int i = nrOfRecord - 1; i >= 0; i--) {
        if (nowTime - stimestamp[i] <= 10.0) {
            NSString *tmp = [NSString stringWithFormat:@"%@\n   major:%zd    minor:%zd   power:%.0f   rssi:%.0f\n\n",
                         [suuid[i] uppercaseString], smajor[i], sminor[i], spower[i], srssi[i]];
            re = [re stringByAppendingString:tmp];
        }
    }
    for (int i = nrOfRecord - 1; i >= 0; i--) {
        if (nowTime - stimestamp[i] > 10.0) {
            NSString *tmp = [NSString stringWithFormat:@"%@       AGE: %.0f\n   major:%zd    minor:%zd   power:%.0f   rssi:%.0f\n\n",
                         [suuid[i] uppercaseString], nowTime - stimestamp[i], smajor[i], sminor[i], spower[i], srssi[i]];
            re = [re stringByAppendingString:tmp];
        }
    }
    //NSLog(@"return: %@", re);
    return re;
}

- (BOOL)isEmpty {
    return nrOfRecord == 0;
}

@end
