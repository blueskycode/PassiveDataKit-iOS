//
//  PDKInstance.m
//  PassiveDataKit
//
//  Created by Chris Karr on 5/4/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PassiveDataKit.h"
#import "PDKLocationGenerator.h"

@interface PassiveDataKit ()

@property NSMutableDictionary * listeners;

@end

NSString * const PDKCapabilityRationale = @"PDKCapabilityRationale";
NSString * const PDKLocationSignificantChangesOnly = @"PDKLocationSignificantChangesOnly";
NSString * const PDKLocationRequestedAccuracy = @"PDKLocationRequestedAccuracy";
NSString * const PDKLocationRequestedDistance = @"PDKLocationRequestedDistance";
NSString * const PDKLocationInstance = @"PDKLocationInstance";

@implementation PassiveDataKit

static PassiveDataKit * sharedObject = nil;

+ (PassiveDataKit *) sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super allocWithZone:nil] init];
        
    });
    
    return sharedObject;
}

+ (id) allocWithZone:(NSZone *) zone
{
    return [self sharedInstance];
}

- (id) init
{
    if (self = [super init])
    {
        self.listeners = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL) registerListener:(id<PDKDataListener>) listener forGenerator:(PDKDataGenerator) dataGenerator options:(NSDictionary *) options {
    NSString * key = [PassiveDataKit keyForGenerator:dataGenerator];
    
    NSMutableArray * dataListeners = [self.listeners valueForKey:key];
    
    if (dataListeners == nil) {
        dataListeners = [NSMutableArray array];
        
        [self.listeners setValue:dataListeners forKey:key];
    }
    
    if ([dataListeners containsObject:listener] == NO) {
        [dataListeners addObject:listener];
        
        [self incrementGenerator:dataGenerator withListener:listener options:options];
    }
    
    return YES;
}

- (BOOL) unregisterListener:(id<PDKDataListener>) listener forGenerator:(PDKDataGenerator) dataGenerator {
    NSString * key = [PassiveDataKit keyForGenerator:dataGenerator];
    
    NSMutableArray * dataListeners = [self.listeners valueForKey:key];
    
    if (dataListeners != nil) {
        [dataListeners removeObject:listener];
        
        [self decrementGenerator:dataGenerator withListener:listener];
    }
    
    return YES;
}

- (void) decrementGenerator:(PDKDataGenerator) generator withListener:(id<PDKDataListener>) listener {
    switch(generator) {
        case PDKLocation:
            [[PDKLocationGenerator sharedInstance] removeListener:listener];
            break;
    }
}

- (void) incrementGenerator:(PDKDataGenerator) generator withListener:(id<PDKDataListener>) listener options:(NSDictionary *) options {
    switch(generator) {
        case PDKLocation:
            [[PDKLocationGenerator sharedInstance] addListener:listener options:options];
            break;
    }
}

+ (NSString *) keyForGenerator:(PDKDataGenerator) generator
{
    switch(generator) {
        case PDKLocation:
            return @"PDKLocationGenerator";
    }

    return @"PDKUnknownGenerator";
}

@end
