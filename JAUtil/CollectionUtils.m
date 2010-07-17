//
//  CollectionUtils.m
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//




#import "CollectionUtils.h"
#import "Test.h"


NSDictionary* _dictof(const struct _dictpair* pairs, size_t count)
{
    CAssert(count<10000);
    id objects[count], keys[count];
    size_t n = 0;
    for( size_t i=0; i<count; i++,pairs++ ) {
        if( pairs->value ) {
            objects[n] = pairs->value;
            keys[n] = pairs->key;
            n++;
        }
    }
    return [NSDictionary dictionaryWithObjects: objects forKeys: keys count: n];
}


NSMutableDictionary* _mdictof(const struct _dictpair* pairs, size_t count)
{
    CAssert(count<10000);
    id objects[count], keys[count];
    size_t n = 0;
    for( size_t i=0; i<count; i++,pairs++ ) {
        if( pairs->value ) {
            objects[n] = pairs->value;
            keys[n] = pairs->key;
            n++;
        }
    }
    return [NSMutableDictionary dictionaryWithObjects: objects forKeys: keys count: n];
}


NSArray* $apply( NSArray *src, SEL selector, id defaultValue )
{
    NSMutableArray *dst = [NSMutableArray arrayWithCapacity: src.count];
    for( id obj in src ) {
        id result = [obj performSelector: selector] ?: defaultValue;
        [dst addObject: result];
    }
    return dst;
}

NSArray* $applyKeyPath( NSArray *src, NSString *keyPath, id defaultValue )
{
    NSMutableArray *dst = [NSMutableArray arrayWithCapacity: src.count];
    for( id obj in src ) {
        id result = [obj valueForKeyPath: keyPath] ?: defaultValue;
        [dst addObject: result];
    }
    return dst;
}


BOOL $equal(id obj1, id obj2)      // Like -isEqual: but works even if either/both are nil
{
    if( obj1 )
        return obj2 && [obj1 isEqual: obj2];
    else
        return obj2==nil;
}


NSValue* _box(const void *value, const char *encoding)
{
    // file:///Developer/Documentation/DocSets/com.apple.ADC_Reference_Library.DeveloperTools.docset/Contents/Resources/Documents/documentation/DeveloperTools/gcc-4.0.1/gcc/Type-encoding.html
    char e = encoding[0];
    if( e=='r' )                // ignore 'const' modifier
        e = encoding[1];
    switch( e ) {
        case 'c':   return [NSNumber numberWithChar: *(char*)value];
        case 'C':   return [NSNumber numberWithUnsignedChar: *(char*)value];
        case 's':   return [NSNumber numberWithShort: *(short*)value];
        case 'S':   return [NSNumber numberWithUnsignedShort: *(unsigned short*)value];
        case 'i':   return [NSNumber numberWithInt: *(int*)value];
        case 'I':   return [NSNumber numberWithUnsignedInt: *(unsigned int*)value];
        case 'l':   return [NSNumber numberWithLong: *(long*)value];
        case 'L':   return [NSNumber numberWithUnsignedLong: *(unsigned long*)value];
        case 'q':   return [NSNumber numberWithLongLong: *(long long*)value];
        case 'Q':   return [NSNumber numberWithUnsignedLongLong: *(unsigned long long*)value];
        case 'f':   return [NSNumber numberWithFloat: *(float*)value];
        case 'd':   return [NSNumber numberWithDouble: *(double*)value];
        case '*':   return [NSString stringWithUTF8String: *(char**)value];
        case '@':   return *(id*)value;
        default:    return [NSValue value: value withObjCType: encoding];
    }
}


id _cast( Class requiredClass, id object )
{
    if( object && ! [object isKindOfClass: requiredClass] )
        [NSException raise: NSInvalidArgumentException format: @"%@ required, but got %@ %p",
         requiredClass,[object class],object];
    return object;
}

id _castNotNil( Class requiredClass, id object )
{
    if( ! [object isKindOfClass: requiredClass] )
        [NSException raise: NSInvalidArgumentException format: @"%@ required, but got %@ %p",
         requiredClass,[object class],object];
    return object;
}

id _castIf( Class requiredClass, id object )
{
    if( object && ! [object isKindOfClass: requiredClass] )
        object = nil;
    return object;
}

NSArray* _castArrayOf(Class itemClass, NSArray *a)
{
    id item;
    foreach( item, $cast(NSArray,a) )
        _cast(itemClass,item);
    return a;
}


void setObj( id *var, id value )
{
    if( value != *var ) {
        [*var release];
        *var = [value retain];
    }
}

BOOL ifSetObj( id *var, id value )
{
    if( value != *var && ![value isEqual: *var] ) {
        [*var release];
        *var = [value retain];
        return YES;
    } else {
        return NO;
    }
}


void setString( NSString **var, NSString *value )
{
    if( value != *var ) {
        [*var release];
        *var = [value copy];
    }
}


BOOL ifSetString( NSString **var, NSString *value )
{
    if( value != *var && ![value isEqualToString: *var] ) {
        [*var release];
        *var = [value copy];
        return YES;
    } else {
        return NO;
    }
}


NSString* $string( const char *utf8Str )
{
    if( utf8Str )
        return [NSString stringWithCString: utf8Str encoding: NSUTF8StringEncoding];
    else
        return nil;
}


@implementation NSArray (MYUtils)

- (BOOL) my_containsObjectIdenticalTo: (id)object
{
    return [self indexOfObjectIdenticalTo: object] != NSNotFound;
}

@end




@implementation NSSet (MYUtils)

+ (NSSet*) my_unionOfSet: (NSSet*)set1 andSet: (NSSet*)set2
{
    if( set1 == set2 || set2.count==0 )
        return set1;
    else if( set1.count==0 )
        return set2;
    else {
        NSMutableSet *result = [set1 mutableCopy];
        [result unionSet: set2];
        return [result autorelease];
    }
}

+ (NSSet*) my_intersectionOfSet: (NSSet*)set1 andSet: (NSSet*)set2
{
    if( set1 == set2 || set1.count==0 )
        return set1;
    else if( set2.count==0 )
        return set2;
    else {
        NSMutableSet *result = [set1 mutableCopy];
        [result intersectSet: set2];
        return [result autorelease];
    }
}

+ (NSSet*) my_differenceOfSet: (NSSet*)set1 andSet: (NSSet*)set2
{
    if( set1.count==0 || set2.count==0 )
        return set1;
    else if( set1==set2 )
        return [NSSet set];
    else {
        NSMutableSet *result = [set1 mutableCopy];
        [result minusSet: set2];
        return [result autorelease];
    }
}

@end



#import "Test.h"

TestCase(CollectionUtils) {
    NSArray *a = $array(@"foo",@"bar",@"baz");
    //Log(@"a = %@",a);
    NSArray *aa = [NSArray arrayWithObjects: @"foo",@"bar",@"baz",nil];
    CAssertEqual(a,aa);
    
    const char *cstr = "a C string";
    id o = $object(cstr);
    //Log(@"o = %@",o);
    CAssertEqual(o,@"a C string");
    
    NSDictionary *d = $dict({@"int",    $object(1)},
                            {@"double", $object(-1.1)},
                            {@"char",   $object('x')},
                            {@"ulong",  $object(1234567UL)},
                            {@"longlong",$object(987654321LL)},
                            {@"cstr",   $object(cstr)});
    //Log(@"d = %@",d);
    NSDictionary *dd = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt: 1],                    @"int",
                        [NSNumber numberWithDouble: -1.1],              @"double",
                        [NSNumber numberWithChar: 'x'],                 @"char",
                        [NSNumber numberWithUnsignedLong: 1234567UL],   @"ulong",
                        [NSNumber numberWithDouble: 987654321LL],       @"longlong",
                        @"a C string",                                  @"cstr",
                        nil];
    CAssertEqual(d,dd);
}


/*
 Copyright (c) 2008, Jens Alfke <jens@mooseyard.com>. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRI-
 BUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
 THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

