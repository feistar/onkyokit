//
//  ONKControllerTest.m
//  OnkyoKit
//
//  Created by Jeff Hutchison on 6/12/13.
//  Copyright (c) 2013 Jeff Hutchison. All rights reserved.
//

@import XCTest;
#import "ONKReceiver_Private.h"
#import "OnkyoKit.h"
#import "ONKCharacteristic_Private.h"

@interface ONKReceiverNetworkTests : XCTestCase <ONKReceiverDelegate>
@property ONKReceiver *receiver;
@property (getter = hasPassed) BOOL passed;
@property NSCondition *condition;
@end

// Tests sending command and receiving corresponding event.
//
// These tests is run as part of the "OnkyoKit Mac Network Tests" scheme. To run
// these tests you must set the ONK_ADDRESS environment variable to the address of
// a suitable Onkyo test device. The ONK_ADDRESS variable is set in the Xcode scheme
// definition.
//
// We utilize NSCondition to synchronize between GCD threads since this is
// asynchronous.
@implementation ONKReceiverNetworkTests

- (void)receiver:(ONKReceiver *)receiver service:(ONKService *)service didUpdateValueForCharacteristic:(ONKCharacteristic *)characteristic
{
    if ([characteristic.code isEqualToString:@"PWR"]) {
        [self.condition lock];
        self.passed = YES;
        [self.condition signal];
        [self.condition unlock];
    }
}

- (void)setUp
{
    [super setUp];
    self.condition = [NSCondition new];
    self.passed = NO;
}

- (void)tearDown
{
    self.condition = nil;
    [super tearDown];
}

- (void)testSendCommand
{
    NSString *address = [[NSProcessInfo processInfo] environment][@"ONK_ADDRESS"];
    NSAssert(address != nil, @"ONK_ADDRESS environment variable must be set - see test comments");

    self.receiver = [[ONKReceiver alloc] initWithModel:@"Test" uniqueIdentifier:@"123" address:address port:60128];
    self.receiver.delegate = self;
    self.receiver.delegateQueue = [[NSOperationQueue alloc] init];
    ONKReceiverSession *session = [[ONKReceiverSession alloc] initWithReceiver:self.receiver];

    NSError *error;
    XCTAssert([session resumeWithError:&error] == YES);
    XCTAssertNil(error);

    [self.condition lock];
    [session sendCommand:@"PWRQSTN" withCompletionHandler:^(NSError *error){
        XCTAssertNil(error);
    }];

    // wait 1 sec for response to be sent.
    [self.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    XCTAssertTrue(self.hasPassed, @"Did not see event for command sent.");
    [self.condition unlock];

    [session suspend];
}

@end
