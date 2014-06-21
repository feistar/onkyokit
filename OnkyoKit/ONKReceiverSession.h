//
//  ONKReceiverSession.h
//  OnkyoKit
//
//  Created by Jeff Hutchison on 6/14/14.
//  Copyright (c) 2014 Jeff Hutchison. All rights reserved.
//

@import Foundation;
@class ONKReceiver;

/**
 * @brief An ONKReceiverSession object represents a network session with a
 * receiver.
 */
@interface ONKReceiverSession : NSObject

/**
 * @brief The associated ONKReceiver instance.
 */
@property (weak, readonly, nonatomic) ONKReceiver *receiver;

/**
 * @brief Contains any encountered error.
 */
@property (nonatomic) NSError *error;

/**
 * @brief Initialize with a configured ONKReceiver object.
 */
- (instancetype)initWithReceiver:(ONKReceiver *)receiver;

/**
 * @brief Start or resume the connection to the remote device.
 */
- (void)resume;

/**
 * @brief Suspend the connection to the remote device.
 */
- (void)suspend;

/**
 * @brief Sends command after 200ms delay.
 */
- (void)sendCommand:(NSString *)command;

@end