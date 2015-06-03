//
//  BonjourUtilClass.h
//  Socket-Client
//
//  Created by xuhui on 15/6/2.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface BonjourUtilClass : NSObject<GCDAsyncSocketDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>{
    NSNetService *netServiceToPublish;
    GCDAsyncSocket *socketPub;
    
    NSNetServiceBrowser *netServiceToBrowse;
    GCDAsyncSocket *socketSub;
    NSMutableArray *mutArrServices;
    
    
    GCDAsyncSocket *socketConnected;
    
}

+(id)sharedInstance;

-(void)startPublishing;
-(void)startBrowsing;
-(void)initConnectionWithService:(NSNetService*)netServiceToConnect;
-(void)disconnectWithCurrent;

@end
