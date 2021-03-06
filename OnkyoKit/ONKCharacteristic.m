//
//  ONKCharacteristic.m
//  OnkyoKit
//
//  Created by Jeff Hutchison on 6/15/14.
//  Copyright (c) 2014 Jeff Hutchison. All rights reserved.
//

#import "ONKCharacteristic_Private.h"
#import "ONKCharacteristicMetadata_Private.h"
#import "ONKService.h"
#import "ONKReceiver_Private.h"

NSString * const ONKCharacteristicTypePowerState   = @"onkyo.pwr";
NSString * const ONKCharacteristicTypeMuteState    = @"onkyo.amt";
NSString * const ONKCharacteristicTypeMasterVolume = @"onkyo.mvl";


NSString * const ONKCharacteristicDefinitionName = @"characteristic.name";
NSString * const ONKCharacteristicDefinitionType = @"characteristic.type";
NSString * const ONKCharacteristicDefinitionCode = @"characteristic.code";
NSString * const ONKCharacteristicDefinitionMetadata = @"characteristic.metadata";

@implementation ONKCharacteristic

- (instancetype)initWithService:(ONKService *)service characteristicDictionary:(NSDictionary *)characteristicDictionary
{
    self = [super init];
    if (self) {
        _service = service;
        _name = characteristicDictionary[ONKCharacteristicDefinitionName];
        _characteristicType = characteristicDictionary[ONKCharacteristicDefinitionType];
        _code = characteristicDictionary[ONKCharacteristicDefinitionCode];
        _metadata = [[ONKCharacteristicMetadata alloc]
                     initWithCharacteristicMetadataDictionary:characteristicDictionary[ONKCharacteristicDefinitionMetadata]];
    }
    return self;
}

- (void)setValue:(id)value
{
    if (![value isEqual:_value]) {
        _value = [value copy];
        ONKService *cachedService = self.service;
        ONKReceiver *cachedReceiver = cachedService.receiver;
        id<ONKReceiverDelegate> cachedDelegate = cachedReceiver.delegate;
        if ([cachedDelegate respondsToSelector:@selector(receiver:service:didUpdateValueForCharacteristic:)]) {
            NSAssert(cachedReceiver.delegateQueue != nil, @"ONKReceiver delegateQueue property not set");
            [cachedReceiver.delegateQueue addOperationWithBlock:^{
                [cachedDelegate receiver:cachedReceiver service:cachedService didUpdateValueForCharacteristic:self];
            }];
        }
    }
}

- (BOOL)boolValue
{
    switch (self.metadata.units) {
        case ONKCharacteristicUnitBoolean:
        case ONKCharacteristicUnitNumeric:
            return [(NSNumber*)self.value boolValue];

        default:
            return NO;
    }
}

- (NSInteger)integerValue
{
    switch (self.metadata.units) {
        case ONKCharacteristicUnitBoolean:
        case ONKCharacteristicUnitNumeric:
            return [(NSNumber*)self.value integerValue];

        default:
            return 0;
    }
}

- (void)handleMessage:(ISCPMessage *)message
{
    NSLog(@"%s code: %@; handling message: %@", __PRETTY_FUNCTION__, self.code, message);
    NSString *payload = [message.message substringFromIndex:3];


    switch (self.metadata.units) {
        case ONKCharacteristicUnitBoolean:
            self.value = [NSNumber numberWithBool:[payload boolValue]];
            break;

        case ONKCharacteristicUnitNumeric: {
            NSScanner *scanner = [NSScanner scannerWithString:payload];
            UInt number;
            if ([scanner scanHexInt:&number]) {
                self.value = [NSNumber numberWithInteger:number];
            } else {
                NSLog(@"NSScanner failed to scan a hexadecimal number in %@", payload);
                self.value = [NSDecimalNumber notANumber];
            }
        }
            break;

        default:
            self.value = payload;
            break;
    }
}

- (NSString *)description
{
    switch (self.metadata.units) {
        case ONKCharacteristicUnitBoolean:
            return [NSString stringWithFormat:@"%@: %@ <%@%02li>",
                    self.name,
                    [self.value boolValue] ? @"ON" : @"OFF",
                    self.code,
                    [self.value integerValue]];

        case ONKCharacteristicUnitNumeric:
            return [NSString stringWithFormat:@"%@: %@ <%@%02lX>",
                    self.name,
                    self.value,
                    self.code,
                    [self.value integerValue]];
            
        case ONKCharacteristicUnitEnum:
            return [NSString stringWithFormat:@"%@: %@ <%@%@>",
                    self.name,
                    self.metadata.enumerationLabels[self.value],
                    self.code,
                    self.value];

        default:
            return [NSString stringWithFormat:@"%@: %@ <%@>",
                    self.name,
                    self.value,
                    self.code];
    }
}


- (void)writeValue:(id)value completionHandler:(void (^)(NSError *error))completion
{
    ONKService *cachedService = self.service;
    ONKReceiver *cachedReceiver = cachedService.receiver;
    NSString *command;

    switch (self.metadata.units) {
        case ONKCharacteristicUnitBoolean:
            command = [NSString stringWithFormat:@"%@%02li",
                    self.code,
                    [value integerValue]];
            break;

        case ONKCharacteristicUnitNumeric:
            command = [NSString stringWithFormat:@"%@%02lX",
                    self.code,
                    [value integerValue]];
            break;
        default:
            return;
    }
    [cachedReceiver sendCommand:command withCompletionHandler:completion];
}

- (void)readValueWithCompletionHandler:(void (^)(NSError *error))completion
{
    ONKService *cachedService = self.service;
    ONKReceiver *cachedReceiver = cachedService.receiver;
    [cachedReceiver sendCommand:[NSString stringWithFormat:@"%@QSTN",self.code] withCompletionHandler:completion];
}


@end
