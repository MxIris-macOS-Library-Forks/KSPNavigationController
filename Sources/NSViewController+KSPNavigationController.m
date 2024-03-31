//
//  KSPViewController.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "NSViewController+KSPNavigationController.h"
#import <objc/runtime.h>

@implementation NSViewController (KSPNavigationController)

- (void)setProposedFirstResponder:(NSView *)proposedFirstResponder {
    objc_setAssociatedObject(self, @selector(proposedFirstResponder), proposedFirstResponder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSView *)proposedFirstResponder {
    return objc_getAssociatedObject(self, @selector(proposedFirstResponder));
}

@end
