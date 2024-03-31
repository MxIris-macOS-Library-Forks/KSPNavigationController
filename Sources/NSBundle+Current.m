//
//  NSBundle+Current.m
//  
//
//  Created by JH on 2024/3/31.
//

#import "NSBundle+Current.h"

@interface KSPBundleToken : NSObject
@end

@implementation KSPBundleToken
@end

@implementation NSBundle (Current)
+ (NSBundle *)currentBundle {
#if SWIFT_PACKAGE
    return SWIFTPM_MODULE_BUNDLE;
#else
    return [NSBundle bundleForClass:[KSPBundleToken class]];
#endif
}
@end
