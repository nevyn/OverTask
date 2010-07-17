//
//  CollectionUtils.h
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//

#import <Foundation/Foundation.h>



// Collection creation conveniences:

#define $array(OBJS...)     ({id objs[]={OBJS}; \
                              [NSArray arrayWithObjects: objs count: sizeof(objs)/sizeof(id)];})
#define $marray(OBJS...)    ({id objs[]={OBJS}; \
                              [NSMutableArray arrayWithObjects: objs count: sizeof(objs)/sizeof(id)];})

#define $dict(PAIRS...)     ({struct _dictpair pairs[]={PAIRS}; \
                              _dictof(pairs,sizeof(pairs)/sizeof(struct _dictpair));})
#define $mdict(PAIRS...)    ({struct _dictpair pairs[]={PAIRS}; \
                              _mdictof(pairs,sizeof(pairs)/sizeof(struct _dictpair));})

#define $object(VAL)        ({__typeof(VAL) v=(VAL); _box(&v,@encode(__typeof(v)));})


// Apply a selector to each array element, returning an array of the results:
NSArray* $apply( NSArray *src, SEL selector, id defaultValue );
NSArray* $applyKeyPath( NSArray *src, NSString *keyPath, id defaultValue );


// Object conveniences:

BOOL $equal(id obj1, id obj2);      // Like -isEqual: but works even if either/both are nil

NSString* $string( const char *utf8Str );

#define $sprintf(FORMAT, ARGS... )  [NSString stringWithFormat: (FORMAT), ARGS]

#define $cast(CLASSNAME,OBJ)        ((CLASSNAME*)(_cast([CLASSNAME class],(OBJ))))
#define $castNotNil(CLASSNAME,OBJ)  ((CLASSNAME*)(_castNotNil([CLASSNAME class],(OBJ))))
#define $castIf(CLASSNAME,OBJ)      ((CLASSNAME*)(_castIf([CLASSNAME class],(OBJ))))
#define $castArrayOf(ITEMCLASSNAME,OBJ) _castArrayOf([ITEMCLASSNAME class],(OBJ)))

void setObj( id *var, id value );
BOOL ifSetObj( id *var, id value );
void setString( NSString **var, NSString *value );
BOOL ifSetString( NSString **var, NSString *value );


#define $true   ((NSNumber*)kCFBooleanTrue)
#define $false  ((NSNumber*)kCFBooleanFalse)


@interface NSArray (MYUtils)
- (BOOL) my_containsObjectIdenticalTo: (id)object;
@end


@interface NSSet (MYUtils)
+ (NSSet*) my_unionOfSet: (NSSet*)set1 andSet: (NSSet*)set2;
+ (NSSet*) my_intersectionOfSet: (NSSet*)set1 andSet: (NSSet*)set2;
+ (NSSet*) my_differenceOfSet: (NSSet*)set1 andSet: (NSSet*)set2;
@end


#pragma mark -
#pragma mark FOREACH:
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
#define foreach(VAR,ARR) for(VAR in ARR)

#else
struct foreachstate {NSArray *array; unsigned n, i;};
static inline struct foreachstate _initforeach( NSArray *arr ) {
    struct foreachstate s;
    s.array = arr;
    s.n = [arr count];
    s.i = 0;
    return s;
}
#define foreach(VAR,ARR) for( struct foreachstate _s = _initforeach((ARR)); \
                                   _s.i<_s.n && ((VAR)=[_s.array objectAtIndex: _s.i], YES); \
                                   _s.i++ )
#endif


// Internals (don't use directly)
struct _dictpair { id key; id value; };
NSDictionary* _dictof(const struct _dictpair*, size_t count);
NSMutableDictionary* _mdictof(const struct _dictpair*, size_t count);
NSValue* _box(const void *value, const char *encoding);
id _cast(Class,id);
id _castNotNil(Class,id);
id _castIf(Class,id);
NSArray* _castArrayOf(Class,NSArray*);

