//
//  ONKReceiverErrorTest.m
//  OnkyoKit
//
//  Created by Jeff Hutchison on 7/21/13.
//  Copyright (c) 2013 Jeff Hutchison. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OnkyoKit/OnkyoKit.h"

@interface ONKReceiverErrorTest : XCTestCase <ONKDelegate>
@property (getter = hasPassed) BOOL passed;
@end

@implementation ONKReceiverErrorTest

- (void)receiver:(ONKReceiver *)receiver didSendEvent:(ONKEvent *)event
{

}

- (void)receiver:(ONKReceiver *)receiver didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    self.passed = YES;
}

- (void)setUp
{
    [super setUp];
    self.passed = NO;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testAddressParseError
{
    ONKReceiver *receiver = [[ONKReceiver alloc] initWithHost:@"-1.-1.-1.-1" onPort:1];
    receiver.delegate = self;
    receiver.delegateQueue = [NSOperationQueue currentQueue];
    [receiver resume];
    XCTAssert(self.hasPassed, @"Did not see didFailWithError called");
}

// assumes this machine is not listening on port 1: Routing Table Maintenance Protocol
- (void)testConnectError
{
    ONKReceiver *receiver = [[ONKReceiver alloc] initWithHost:@"127.0.0.1" onPort:1];
    receiver.delegate = self;
    receiver.delegateQueue = [NSOperationQueue currentQueue];
    [receiver resume];
    XCTAssert(self.hasPassed, @"Did not see didFailWithError called");
}
@end
