//
//  BLCSendingFile.m
//  BeaconOSX
//
//  Created by Bo Jhang Ho on 3/17/14.
//  Copyright (c) 2014 Blended Cocoa. All rights reserved.
//

#import "BLCSendingFile.h"
#include <sys/socket.h>
#include <netinet/in.h>

@interface BLCSendingFile () {
    char ip[100];
    int port;
    
    char myuuid[50];
    int mymajor;
    int myminor;
    double mypower;
    
    char suuid[100][50];
    int smajor[100];
    int sminor[100];
    double spower[100];
    double srssi[100];
    double stimestamp[100];
    
    int nrOfRecord;
    NSTimer *timer;
    
    bool critical;
    
    BLCAppDelegate *appReceiver;
    
    int noUpdateCount;
}

@end

@implementation BLCSendingFile

- (id)initWithIp:(const char*)_ip port:(int)_port {
    strcpy(ip, _ip);
    port = _port;
    nrOfRecord = 0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2
                                             target:self
                                           selector:@selector(upload)
                                           userInfo:nil
                                            repeats:YES];
    critical = false;
    noUpdateCount = 0;
    return self;
}

- (void)setMyInfoUUID:(const char *)uuid myMajor:(int)major myMinor:(int)minor myPower:(double)power {
    while (critical);
    
    strcpyUUID(myuuid, uuid);
    mymajor = major;
    myminor = minor;
    mypower = power;
}

- (void)setReceiver:(BLCAppDelegate*)receiver {
    appReceiver = receiver;
}

- (void)insertUUID:(const char *)uuid major:(int)major minor:(int)minor power:(double)power rssi:(double)rssi timestamp:(double)timestamp {
    while (critical);
    
    strcpyUUID(suuid[nrOfRecord], uuid);
    smajor[nrOfRecord] = major;
    sminor[nrOfRecord] = minor;
    spower[nrOfRecord] = power;
    srssi[nrOfRecord] = rssi;
    stimestamp[nrOfRecord] = timestamp;
    nrOfRecord++;
    if (nrOfRecord == 100)
        nrOfRecord--;
}

- (void)updateIp:(const char*)_ip port:(int)_port {
    NSLog(@"update %s %d", _ip, _port);
    strcpy(ip, _ip);
    port = _port;
}

- (void)upload {
    if (nrOfRecord > 0) {
        int sockfd;
        struct sockaddr_in servaddr;
        
        sockfd=socket(AF_INET,SOCK_STREAM,0);
        
        bzero(&servaddr,sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = inet_addr(ip);
        servaddr.sin_port = htons(port);
        
        if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) != 0) {
            NSLog(@"cannot connect to server");
            noUpdateCount++;
            if (noUpdateCount >= 5)
                [appReceiver showInit];
            return ;
        }
        
        critical = true;
        char message[10000];
        char buffer[10000];
        char tmp[1000];
        strcpy(message, "");
        sprintf(tmp, "%s %d %d %.0lf\n", myuuid, mymajor, myminor, mypower);
        strcat(message, tmp);
        //sprintf(tmp, "%d\n", nrOfRecord);
        //strcat(message, tmp);
        for (int i = 0; i < nrOfRecord; i++) {
            sprintf(tmp, "%s %d %d %.0lf %.0lf %.0lf\n", suuid[i], smajor[i], sminor[i], spower[i], srssi[i], stimestamp[i]);
            strcat(message, tmp);
        }
        nrOfRecord = 0;
        //NSLog(@"%s", message);
        
        int len = (int)strlen(message);
        
        critical = false;
        
        sendto(sockfd, message, len, 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
        message[0] = '\0';
        int re;
        while ((re = (int)recv(sockfd, buffer, 1000, 0)) > 0) {
            //NSLog(@"aha");
            buffer[re] = '\0';
            strcat(message, buffer);
        }
        
        //message[re] = '\0';
        NSLog(@"message: %s", message);
        
        close(sockfd);
        
        
        char *p = strtok(message, " \n\t\r");
        int nrOfElement = 0;
        int meInd = -1;
        double mex, mey;
        if (p == NULL) {
            noUpdateCount++;
            if (noUpdateCount >= 5)
                [appReceiver showInit];
            return;
        }
        
        
        sscanf(p, "%d", &nrOfElement);
        if (nrOfElement == 0) {
            noUpdateCount++;
            if (noUpdateCount >= 5)
                [appReceiver showInit];
            return;
        }
        
        
        char tuuid[10][100];
        int tmajor[10];
        int tminor[10];
        double tx[10];
        double ty[10];
        
        int ii;
        for (ii = 0; ii < nrOfElement; ii++) {
            if ((p = strtok(NULL, " \n\t")) == NULL || sscanf(p, "%s", tuuid[ii]) != 1)
                break;
            //NSLog(@"1");sscanf(p, "%s", tuuid);
            if ((p = strtok(NULL, " \n\t")) == NULL || sscanf(p, "%d", &tmajor[ii]) != 1)
                break;
            //NSLog(@"1");
            if ((p = strtok(NULL, " \n\t")) == NULL || sscanf(p, "%d", &tminor[ii]) != 1)
                break;
            //NSLog(@"1");
            if ((p = strtok(NULL, " \n\t")) == NULL || sscanf(p, "%lf", &tx[ii]) != 1)
                break;
            //NSLog(@"1");
            if ((p = strtok(NULL, " \n\t")) == NULL || sscanf(p, "%lf", &ty[ii]) != 1)
                break;
            //NSLog(@"final: %s %d %d %lf %lf", tuuid, tmajor, tminor, tx, ty);
            
            if (strcmp(myuuid, tuuid[ii]) == 0 && mymajor == tmajor[ii] && myminor == tminor[ii]) {
                meInd = ii;
                mex = tx[ii];
                mey = ty[ii];
            }
        }
        
        NSLog(@"meInd = %d %s", meInd, myuuid);
        
        nrOfElement = ii;
        if (meInd != -1) {
            //for (int i = 0; i < nrOfElement; i++) {
            //    tx[i] -= mex;
            //    ty[i] -= mey;
            //}
            
            for (int i = 0; i < 10; i++) {
                if (i >= nrOfElement)
                    [appReceiver hideInd:i];
                else if (i == meInd)
                    [appReceiver showMeInd:i x:tx[i] y:ty[i]];
                else {
                    char trunc[100];
                    for (int j = 0; j < 8; j++)
                        trunc[j] = tuuid[i][j];
                    trunc[8] = '\0';
                    NSString *ts = [[NSString alloc] initWithFormat:@"uuid:%s...\nmajor:%d\nminor:%d", trunc, tmajor[i], tminor[i]];
                    [appReceiver showInd:i str:ts x:tx[i] y:ty[i]];
                }
            }
            noUpdateCount = 0;
        }
    }
}

void strcpyUUID(char *dst, const char *src) {
    int dlen = 0;
    for (int i = 0; src[i] && i < 50; i++) {
        if ('0' <= src[i] && src[i] <='9')
            dst[dlen++] = src[i];
        else if ('a' <= src[i] && src[i] <='f')
            dst[dlen++] = src[i];
        else if ('A' <= src[i] && src[i] <='F')
            dst[dlen++] = src[i] - 'A' + 'a';
    }
    dst[dlen] = '\0';
}

@end
