//
//  TBSMDebugLogger.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.10.16.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import "TBSMDebugLogger.h"

@interface TBSMDebugLogger ()

#if OS_OBJECT_HAVE_OBJC_SUPPORT == 0
@property (nonatomic, assign) dispatch_queue_t loggingQueue;
#else
@property (nonatomic, strong) dispatch_queue_t loggingQueue;
#endif

@end

@implementation TBSMDebugLogger

+ (instancetype)sharedInstance
{
    static TBSMDebugLogger *_debugLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _debugLogger = [TBSMDebugLogger new];
    });
    return _debugLogger;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loggingQueue = dispatch_queue_create("jkrumow.TBStateMachine.DebugLogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 0
    dispatch_release(self.loggingQueue);
#endif
}

- (void)log:(NSString *)format, ...
{
    NSString *logMessage;
    va_list args;
    va_start(args, format);
    logMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    dispatch_async(self.loggingQueue, ^{
        NSLog(logMessage);
    });
}
@end
