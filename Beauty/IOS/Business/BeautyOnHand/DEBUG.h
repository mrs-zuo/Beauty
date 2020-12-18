//
//  DEBUG.h
//  jinliyu
//
//  Created by QFish on 8/27/12.
//  Copyright (c) 2013 GuanHui. All rights reserved.
//
	
#import <Foundation/Foundation.h>

//#define TESTDEBUG

#ifdef TESTDEBUG

    #define DLOG(format, ...)        \
        NSLog(@"*****%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
    #define NSLog(format, ...)        \
    NSLog(@"%@", [NSString stringWithFormat:format, ## __VA_ARGS__])

    #define _po(o) NSLog(@"*****%@", (o))
    #define _pn(o) NSLog(@"*****%d", (o))
    #define _pf(o) NSLog(@"*****%f", (o))
    #define _pSize(o) NSLog(@"*****CGSize: {%.0f, %.0f}", (o).width, (o).height)
    #define _pPoint(o) NSLog(@"*****CGPoint: {%.0f, %.0f}", (o).x, (o).y)
    #define _pIndexPath(o) NSLog(@"*****IndexPath: section:%ld row:%ld", (o).section, (o).row )

    #define _pframe(o) NSLog(@"*****NSRect: {{%.0f, %.0f}, {%.0f, %.0f}}", (o).origin.x, (o).origin.x, (o).size.width, (o).size.height)

    #define DOBJ(obj)  NSLog(@"*****%s: %@", #obj, [(obj) description])

    #define MARK    NSLog(@"*****MARK: %s, %d", __PRETTY_FUNCTION__, __LINE__)

    #define START_TIMER                 \
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    #define END_TIMER(msg)              \
        NSLog([NSString stringWithFormat:"*****%@ Time = %f", msg, \
        [NSDate timeIntervalSinceReferenceDate]-start]);
#else

    #define DLOG(format, ...)
    #define NSLog(format, ...)
    #define DOBJ(obj)
    #define MARK
    #define START_TIMER
    #define END_TIMER
    #define _pSize(o)
    #define _pPoint(o)
    #define _pframe(o)
    #define _pIndexPath(o)

#endif

#ifdef TESTDEBUG

    #define LOG(...) DLog(__VA_ARGS__)
    #define LOG_METHOD \
        NSLog(@"*****Line:%d\nFunction:%s\n", __LINE__, __FUNCTION__)
#else
    #define LOG(...)
    #define LOG_METHOD
#endif

#ifdef TESTDEBUG
    #define MCRelease(x) [(x) release]
#else
    #define MCRelease(x) [(x) release], (x) = nil
#endif

//--Plug-in Switching
//#define ThirdPush
#define IConsole
#define AFHTTPClientLog


