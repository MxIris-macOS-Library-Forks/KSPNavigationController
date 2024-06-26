//
//  KPBackButtonCell.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPBackButtonCell.h"
#import "NSBundle+Current.h"
// * * *.

static NSImage* arrowDisabled;

static NSImage *arrowNormal;

static NSImage *arrowHighlighted;

// * * *.

@implementation KSPBackButtonCell

#pragma mark - NSObject Overrides

+ (void) initialize
{
  arrowDisabled = [[NSBundle currentBundle] imageForResource: @"Arrow-disabled"];
  
  arrowNormal = [[NSBundle currentBundle] imageForResource: @"Arrow-normal"];
  
  arrowHighlighted = [[NSBundle currentBundle] imageForResource: @"Arrow-highlighted"];
}

#pragma mark - NSCell Overrides

- (NSRect) titleRectForBounds: (NSRect) bounds
{
  const NSRect supers = [super titleRectForBounds: bounds];

  return NSMakeRect(bounds.size.width - supers.size.width, supers.origin.y, supers.size.width, supers.size.height);
}

#pragma mark - NSButtonCell Overrides

- (void) drawBezelWithFrame: (NSRect) frame inView: (NSView*) controlView
{
  const NSRect r = NSMakeRect(0, 0, arrowNormal.size.width, arrowNormal.size.height);
  
  if(self.isEnabled)
  {
    if(self.isHighlighted)
    {
        [arrowHighlighted drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositingOperationSourceOver fraction: 1];
    }
    else
    {
        [arrowNormal drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositingOperationSourceOver fraction: 1];
    }
  }
  else
  {
      [arrowDisabled drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositingOperationSourceOver fraction: 1];
  }
}

@end
