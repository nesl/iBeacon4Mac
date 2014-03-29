//
//  Copyright (c) 2013, Matthew Robinson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of Blended Cocoa nor the names of its contributors may
//     be used to endorse or promote products derived from this software without
//     specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//
//
//  BLCAppDelegate.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//

#import "BLCAppDelegate.h"

#import <IOBluetooth/IOBluetooth.h>

#import "BLCBeaconAdvertisementData.h"
#import "BLCbeaconList.h"
#import "BLCSendingFile.h"

#define DEBUG_CENTRAL YES
#define DEBUG_PERIPHERAL YES
#define DEBUG_PROXIMITY NO


@interface BLCAppDelegate () <CBCentralManagerDelegate, CBPeripheralManagerDelegate, NSTextFieldDelegate> {
    CBCentralManager *centralManager;
    FILE *fout;
    BOOL isScanning;
    
    NSString *suuid[100];
    NSInteger smajor[100];
    NSInteger sminor[100];
    double spower[100];
    double srssi[100];
    double stimestamp[100];
    BLCbeaconList *beaconList;
    NSTimer *timer;
    
    NSTextField *dis[10];
    NSColorWell *well[10];
    
    BLCSendingFile *sendingFile;
}

@property (nonatomic,strong) CBPeripheralManager *manager;



- (IBAction)startButtonTapped:(NSButton*)advertisingButton;

@end

@implementation BLCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                       queue:nil];
    beaconList = [[BLCbeaconList alloc] init];
    [startbutton setEnabled:NO];
    [startbutton setAction:@selector(startButtonTapped:)];
    [startbuttonListener setAction:@selector(startButtonScanning:)];
    [checkboxWriteFile setAction:@selector(checkboxWriteFileTapped:)];
    [checkboxConnectServer setAction:@selector(checkboxConnectServerTapped:)];
    
    [fileNameTextField setStringValue:[[NSString alloc] initWithFormat:@"/users/timestring/ibeaconData/measure_%.0f.txt", CFAbsoluteTimeGetCurrent()]];
    
    sendingFile = [[BLCSendingFile alloc] initWithIp:"172.17.5.37" port:30001];
    [sendingFile setMyInfoUUID:[[uuidTextField stringValue] UTF8String]
                       myMajor:(int)majorValueTextField.integerValue
                       myMinor:(int)minorValueTextField.integerValue
                       myPower:measuredPowerTextField.doubleValue];
    
    dis[0] = dis1;
    dis[1] = dis2;
    dis[2] = dis3;
    dis[3] = dis4;
    dis[4] = dis5;
    dis[5] = dis6;
    dis[6] = dis7;
    dis[7] = dis8;
    dis[8] = dis9;
    dis[9] = dis10;
    
    well[0] = well1;
    well[1] = well2;
    well[2] = well3;
    well[3] = well4;
    well[4] = well5;
    well[5] = well6;
    well[6] = well7;
    well[7] = well8;
    well[8] = well9;
    well[9] = well10;
    
    [self showInit];
    
    [sendingFile setReceiver:self];
    
    uuidTextField.delegate = self;
    fileNameTextField.delegate = self;
    textfieldServerIP.delegate = self;
    textFieldServerPort.delegate = self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [startbutton setEnabled:YES];
        [uuidTextField setEnabled:YES];
        [majorValueTextField setEnabled:YES];
        [minorValueTextField setEnabled:YES];
        [measuredPowerTextField setEnabled:YES];
        
        [startbutton setTarget:self];
        
        
        
    }
}

- (IBAction)startButtonTapped:(NSButton*)advertisingButton {
    if (_manager.isAdvertising) {
        [_manager stopAdvertising];
        [advertisingButton setTitle:@"start Advertising"];
        [uuidTextField setEnabled:YES];
        [majorValueTextField setEnabled:YES];
        [minorValueTextField setEnabled:YES];
        [measuredPowerTextField setEnabled:YES];
    } else {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:[uuidTextField stringValue]];
        
        BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                                     major:majorValueTextField.integerValue
                                                                                                     minor:minorValueTextField.integerValue
                                                                                             measuredPower:measuredPowerTextField.integerValue];
        
        [sendingFile setMyInfoUUID:[[uuidTextField stringValue] UTF8String]
                           myMajor:(int)majorValueTextField.integerValue
                           myMinor:(int)minorValueTextField.integerValue
                           myPower:measuredPowerTextField.doubleValue];
        
        [_manager startAdvertising:beaconData.beaconAdvertisement];
        [uuidTextField setEnabled:NO];
        [majorValueTextField setEnabled:NO];
        [minorValueTextField setEnabled:NO];
        [measuredPowerTextField setEnabled:NO];

        [advertisingButton setTitle:@"Stop Broadcasting"];
    }
    
    
}

- (IBAction)startButtonScanning:(NSButton*)scanningButton {
    if (isScanning == NO) {
        
        if ([checkboxWriteFile state] == NSOnState) {
            char fileName[1000];
            [fileNameTextField validateEditing];
            //NSLog(@"ff %@", [fileNameTextField stringValue]);
            sprintf(fileName, "%s", [[fileNameTextField stringValue] UTF8String]);
            fout = fopen(fileName, "r");
            if (fout != NULL) {
                fclose(fout);
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Error"];
                [alert setInformativeText:@"File existed."];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
                return ;
            }
            //NSLog(@"%s", fileName);
            fclose(fout);
            fout = fopen(fileName, "w");
            if (fout == NULL) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Error"];
                [alert setInformativeText:@"Cannot creaete file."];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
                return ;
            }
            //[fileNameTextField setStringValue:[[NSString alloc] initWithFormat:@"%s", fileName]];
            //NSLog(@"ffff %@", [fileNameTextField stringValue]);
        }
        if ([checkboxConnectServer state] == NSOnState) {
            [sendingFile updateIp:[[textfieldServerIP stringValue] UTF8String] port:textFieldServerPort.intValue];
        }
        
        [startbuttonListener setTitle:@"stop Scanning"];
        ibeaconStatusTextField.stringValue = @"(detecting...)";
        
        [fileNameTextField setEnabled:NO];
        [textfieldServerIP setEnabled:NO];
        [textFieldServerPort setEnabled:NO];
        [checkboxWriteFile setEnabled:NO];
        [checkboxConnectServer setEnabled:NO];
        
        [self startDetecting];
        [sendingFile setReceiver:self];
    }
    else {
        [startbuttonListener setTitle:@"start Scanning"];
        [checkboxWriteFile setEnabled:YES];
        [checkboxConnectServer setEnabled:YES];
        if ([checkboxWriteFile state] == NSOnState)
            [fileNameTextField setEnabled:YES];
        if ([checkboxConnectServer state] == NSOnState) {
            [textfieldServerIP setEnabled:YES];
            [textFieldServerPort setEnabled:YES];
        }
        [self stopDetecting];
        [timer invalidate];
        if ([beaconList isEmpty])
            ibeaconStatusTextField.stringValue = [NSString stringWithFormat:@"stop detecting"];
        else
            ibeaconStatusTextField.stringValue = [NSString stringWithFormat:@"Last Result Below\n\n%@", [beaconList getText]];
    }
    isScanning = !isScanning;
}


- (IBAction)checkboxWriteFileTapped:(NSButton*)button {
    if ([button state] == NSOnState) {
        [fileNameTextField setEnabled:YES];
    }
    else {
        [fileNameTextField setEnabled:NO];
    }
}

- (IBAction)checkboxConnectServerTapped:(NSButton*)button {
    if ([button state] == NSOnState) {
        [textfieldServerIP setEnabled:YES];
        [textFieldServerPort setEnabled:YES];
    }
    else {
        [textfieldServerIP setEnabled:NO];
        [textFieldServerPort setEnabled:NO];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    NSLog(@"enter");
    
    return YES;
}


- (void)startDetecting {
    if (![self canMonitorBeacons])
        return;
    
    NSLog(@"has ability to monitor beacons ??");
    [self startDetectingBeacons];
}

- (void)stopDetecting {
    [centralManager stopScan];
    centralManager = nil;
    fclose(fout);
}

- (void)startDetectingBeacons {
    if (!centralManager)
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //detectorTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self
    //                                               selector:@selector(reportRangesToDelegates:) userInfo:nil repeats:YES];
}

- (BOOL)canMonitorBeacons {
    return YES;
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (DEBUG_PERIPHERAL) {
        //NSLog(@"did discover peripheral: %@, data: %@, %1.2f", [peripheral.identifier UUIDString], advertisementData, [RSSI floatValue]);
        //NSLog(@"did discover peripheral: %@, %1.2f", [peripheral.identifier UUIDString], [RSSI floatValue]);
        
        //NSLog(@"UUIDsKey is: %@", CBAdvertisementDataServiceUUIDsKey);
        //NSLog(@"type of ad[uuid] = %@", NSStringFromClass([[advertisementData valueForKey:@"kCBAdvDataManufacturerData"] class]));
        //NSLog(@"service UUID of advertisement data: %@", [advertisementData valueForKey:@"kCBAdvDataManufacturerData"]);
        //CBUUID *uuid = [advertisementData[CBAdvertisementDataServiceUUIDsKey] firstObject];
        //NSLog(@"service uuid: %@", [self uuidToString:uuid]);
        //NSLog(@"--------------------------");
    }
    
    if ([advertisementData valueForKey:@"kCBAdvDataManufacturerData"] != nil) {
        NSData *data = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
        /*NSLog(@"uuid: %@", [self uuidByteToString:([data bytes] + 4)]);
        NSLog(@"major: %zd", [self shortByteToInt:([data bytes] + 20)]);
        NSLog(@"minor: %zd", [self shortByteToInt:([data bytes] + 22)]);
        NSLog(@"power: %zd", [self charByteToInt:([data bytes] + 24)]);
        NSLog(@"rssi: %@", RSSI);
        NSLog(@"------------------------------");*/
        
        double nowTime = CFAbsoluteTimeGetCurrent();
        NSString *uuid = [self uuidByteToString:([data bytes] + 4)];
        NSInteger major = [self shortByteToInt:([data bytes] + 20)];
        NSInteger minor = [self shortByteToInt:([data bytes] + 22)];
        double power = [self charByteToInt:([data bytes] + 24)];
        double rssi = [RSSI doubleValue];
        
        if (fout != NULL) {
            fprintf(fout, "%f %s %zd %zd %f %f\n", nowTime, [uuid UTF8String], major, minor, power, rssi);
            fflush(fout);
        }
        if ([checkboxConnectServer state] == NSOnState) {
            [sendingFile insertUUID:[uuid UTF8String] major:(int)major minor:(int)minor power:power rssi:rssi timestamp:nowTime];
        }
        [beaconList inputTime:nowTime uuid:uuid major:major minor:minor power:power rssi:rssi];
        [ibeaconStatusTextField setStringValue:[beaconList getText]];
        //NSLog(@"%@", [beaconList getText]);
        
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(updateStat)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    
    //_RSSI = [RSSI floatValue];
    //NSLog(@"%f", _RSSI);
    //identifierRange = [self convertRSSItoINProximity:[RSSI floatValue]];
    
    
    /*[self performBlockOnDelegates:^(id<INBeaconServiceDelegate>delegate) {
        [delegate service:self foundDeviceUUID:[identifier representativeString] withRange:identifierRange withRSSI:_RSSI];
    } complete:^{
        // timeout the beacon to unknown position
        // it it's still active it will be updated by central delegate "didDiscoverPeripheral"
        identifierRange = INDetectorRangeUnknown;
    }];*/
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (DEBUG_CENTRAL)
        NSLog(@"-- central state changed: %@", [self centralManagerStateString:central]);
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self startScanning];
    }
    
}

- (void)startScanning
{
    
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
    
    
    //[centralManager scanForPeripheralsWithServices:@[identifier] options:scanOptions];
    [centralManager scanForPeripheralsWithServices:nil options:scanOptions];
    //_isDetecting = YES;
    
    
    // // write files
    
    
    //fprintf(fout, "hello wo bo jo\n");
    //fclose(fout);
    //NSLog(@"should write something");
}

- (NSString *)uuidToString:(CBUUID *)uuid
{
    return [self uuidByteToString:[uuid.data bytes]];
}


- (NSString *)uuidByteToString:(const void *)bytes {
    const unsigned char *cbytes = bytes;
    NSMutableString *outputString = [NSMutableString stringWithCapacity:20];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < 16; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", cbytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", cbytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

- (NSInteger)shortByteToInt:(const void *)bytes {
    const unsigned char *cbytes = bytes;
    NSInteger re = 0;
    re = cbytes[1] | (cbytes[0] << 8);
    return re;
}

- (NSInteger)charByteToInt:(const void *)bytes {
    const char *cbytes = bytes;
    return (NSInteger)cbytes[0];
}

- (NSString *)centralManagerStateString:(CBCentralManager *)manager {
    switch (manager.state) {
        case CBCentralManagerStatePoweredOff:
            return @"Powered Off";
            break;
            
        case CBCentralManagerStateResetting:
            return @"Resetting";
            break;
            
        case CBCentralManagerStatePoweredOn:
            return @"Powered On";
            break;
            
        case CBCentralManagerStateUnauthorized:
            return @"Unauthorized";
            break;
            
        case CBCentralManagerStateUnknown:
            return @"Unknown";
            break;
            
        case CBCentralManagerStateUnsupported:
            return @"Unsupported";
            break;
    }
}

- (void)updateStat {
    ibeaconStatusTextField.stringValue = [beaconList getText];
}

- (void)hideInd:(int)ind {
    [dis[ind] setFrameOrigin:NSMakePoint(-200, -200)];
    [well[ind] setFrameOrigin:NSMakePoint(-200, -200)];

}

- (void)showInd:(int)ind str:(NSString*)str x:(double)x y:(double)y {
    //NSLog(@"showInd: %d %@ %f %f", ind, str, x, y);
    x *= 15.0;
    y *= 15.0;
    if (x < -200.0 || x > 200.0 || y < -200.0 || y > 200.0)
        [self hideInd:ind];
    else {
        x += 683;
        y += 220;
        [dis[ind] setFrameOrigin:NSMakePoint(x + 5, y - 35)];
        [well[ind] setFrameOrigin:NSMakePoint(x, y)];
        [dis[ind] setStringValue:str];
    }
}

- (void)showMeInd:(int)ind x:(double)x y:(double)y {
    //x *= 15.0;
    //y *= 15.0;
    [wellOri setFrameOrigin:NSMakePoint(x * 15 + 603, y * 15 + 220)];
    [disNothing setFrameOrigin:NSMakePoint(-200, -200)];
}

- (void)showInit {
    for (int i = 0; i < 10; i++) {
        [dis[i] setFrameOrigin:NSMakePoint(-200, -200)];
        [well[i] setFrameOrigin:NSMakePoint(-200, -200)];
    }
    
    [wellOri setFrameOrigin:NSMakePoint(-20, -20)];
    [disNothing setFrameOrigin:NSMakePoint(519, 251)];
}

@end
