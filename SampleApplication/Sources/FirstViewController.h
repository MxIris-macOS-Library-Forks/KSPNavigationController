//
//  FirstViewController.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 02/12/15.
//  Copyright © 2016 Konstantin Pavlikhin. All rights reserved.
//

@import KSPNavigationController;

@interface FirstViewController : NSViewController<KSPNavigableViewController>

@property(readwrite, weak, nonatomic) KSPNavigationController* navigationController;

@property(readwrite, strong, nonatomic) IBOutlet NSButton* backButton;

@property(readwrite, strong, nonatomic) IBOutlet NSView* leftNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* centerNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* rightNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationToolbar;

@end
