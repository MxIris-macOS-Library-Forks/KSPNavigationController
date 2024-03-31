//
//  KPNavigationControllerDelegate.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/12/13.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol KSPNavigableViewController;

@class KSPNavigationController;

NS_ASSUME_NONNULL_BEGIN

@protocol KSPNavigationControllerDelegate <NSObject>

@optional

- (void)navigationController:(KSPNavigationController *)navigationController willShowViewController:(NSViewController<KSPNavigableViewController> *)viewController animated:(BOOL)animated;

- (void)navigationController:(KSPNavigationController *)navigationController didShowViewController:(NSViewController<KSPNavigableViewController> *)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
