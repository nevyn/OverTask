//
//  Logging.h
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//

#import <Foundation/Foundation.h>



NSString* LOC( NSString *key );     // Localized string lookup


// To enable IN_SEGMENT (which breaks rarely-called logging code out of your main code segment,
// improving locality of reference) you must define MY_USE_NESTED_FNS in your prefix file or
// target settings, and add the GCC flag "-fnested-functions" to your target's C flags.
#if defined(MY_USE_NESTED_FNS) && ! defined(__cplusplus)
    #define IN_SEGMENT(SEG) auto __attribute__ ((section ("__TEXT, "#SEG))) __attribute__ ((noinline)) void _outofband_(void);\
                            _outofband_();\
                            void _outofband_(void)
    #define IN_SEGMENT_NORETURN(SEG) auto __attribute__ ((section ("__TEXT, "#SEG))) __attribute__ ((noinline)) __attribute__((noreturn)) void _assertfailure_(void);\
                            _assertfailure_();\
                            void _assertfailure_(void)
#else
    #define IN_SEGMENT(SEG)
    #define IN_SEGMENT_NORETURN(SEG)
#endif

#define Log(FMT,ARGS...) do{if(__builtin_expect(_gShouldLog,0)) {\
                            IN_SEGMENT(Logging){_Log(FMT,##ARGS);}\
                         } }while(0)
#define LogTo(DOMAIN,FMT,ARGS...) do{if(__builtin_expect(_gShouldLog,0)) {\
                                    IN_SEGMENT(Logging) {if(_WillLogTo(@""#DOMAIN)) _LogTo(@""#DOMAIN,FMT,##ARGS);}\
                                  } }while(0)
#define Warn Warn

void AlwaysLog( NSString *msg, ... ) __attribute__((format(__NSString__, 1, 2)));
BOOL _WillLogTo( NSString *domain );
BOOL EnableLog( BOOL enable );
#define EnableLogTo( DOMAIN, VALUE )  _EnableLogTo(@""#DOMAIN, VALUE)
#define WillLogTo( DOMAIN )  _WillLogTo(@""#DOMAIN)


// internals; don't use directly
extern int _gShouldLog;
void _Log( NSString *msg, ... ) __attribute__((format(__NSString__, 1, 2)));
void Warn( NSString *msg, ... ) __attribute__((format(__NSString__, 1, 2)));
void _LogTo( NSString *domain, NSString *msg, ... ) __attribute__((format(__NSString__, 2, 3)));
BOOL _WillLogTo( NSString *domain );
BOOL _EnableLogTo( NSString *domain, BOOL enable );

