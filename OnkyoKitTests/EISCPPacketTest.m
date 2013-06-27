//
//  EISCPPacketTest.m
//  OnkyoKit
//
//  Created by Jeff Hutchison on 6/22/13.
//  Copyright (c) 2013 Jeff Hutchison. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OnkyoKit/EISCPPacket.h>
#import <OnkyoKit/ISCPMessage.h>

@interface EISCPPacketTest : XCTestCase

@end

@implementation EISCPPacketTest

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testHeader {
    ISCPMessage *message = [[ISCPMessage alloc] initWithMessage:@"PWRQSTN"];
    EISCPPacket *packet = [[EISCPPacket alloc] initWithMessage:message];
    XCTAssertEqualObjects(packet.magic, @"ISCP");
    XCTAssertEquals(packet.headerLength, 16UL);
    XCTAssertEquals(packet.dataLength, 10UL);
    XCTAssertEquals(packet.version, 1UL);
}

@end