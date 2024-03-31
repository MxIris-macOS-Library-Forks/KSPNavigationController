//
//  KSPViewController.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSViewController (KSPNavigationController)

@property(readwrite, strong, nonatomic) NSView* proposedFirstResponder;

@end
