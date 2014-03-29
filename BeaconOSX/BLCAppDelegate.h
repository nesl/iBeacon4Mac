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
//  BLCAppDelegate.h
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//

#import <Cocoa/Cocoa.h>

@interface BLCAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSButton  *startbutton;
    IBOutlet NSTextField *uuidTextField;
    IBOutlet NSTextField *majorValueTextField;
    IBOutlet NSTextField *minorValueTextField;
    IBOutlet NSTextField *measuredPowerTextField;
    
    IBOutlet NSButton  *startbuttonListener;
    IBOutlet NSTextField *ibeaconStatusTextField;
    
    IBOutlet NSButton *checkboxWriteFile;
    IBOutlet NSTextField *fileNameTextField;
    IBOutlet NSButton *checkboxConnectServer;
    IBOutlet NSTextField *textfieldServerIP;
    IBOutlet NSTextField *textFieldServerPort;
    
    IBOutlet NSTextField *dis1;
    IBOutlet NSTextField *dis2;
    IBOutlet NSTextField *dis3;
    IBOutlet NSTextField *dis4;
    IBOutlet NSTextField *dis5;
    IBOutlet NSTextField *dis6;
    IBOutlet NSTextField *dis7;
    IBOutlet NSTextField *dis8;
    IBOutlet NSTextField *dis9;
    IBOutlet NSTextField *dis10;
    
    IBOutlet NSColorWell *well1;
    IBOutlet NSColorWell *well2;
    IBOutlet NSColorWell *well3;
    IBOutlet NSColorWell *well4;
    IBOutlet NSColorWell *well5;
    IBOutlet NSColorWell *well6;
    IBOutlet NSColorWell *well7;
    IBOutlet NSColorWell *well8;
    IBOutlet NSColorWell *well9;
    IBOutlet NSColorWell *well10;
    
    IBOutlet NSColorWell *wellOri;
    IBOutlet NSTextField *disNothing;
}

@property (assign) IBOutlet NSWindow *window;

- (void)hideInd:(int)ind;
- (void)showInd:(int)ind str:(NSString*)str x:(double)x y:(double)y;
- (void)showMeInd:(int)ind x:(double)x y:(double)y;
- (void)showInit;

@end
