#import <AppKit/AppKit.h>

typedef NS_ENUM(NSUInteger, KSPNavigationControllerTransitionStyle) {
    KSPNavigationControllerTransitionStyleLengthy,
    KSPNavigationControllerTransitionStyleShort
} NS_SWIFT_NAME(KSPNavigationController.TransitionStyle);

@class KSPHitTestView;

@protocol KSPNavigableViewController;

@protocol KSPNavigationControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface KSPNavigationController : NSViewController

@property (nonatomic, strong, readonly) IBOutlet KSPHitTestView *navigationBar;

/// KSPNavigationControllerTransitionStyleLengthy by default.
@property (nonatomic, assign) KSPNavigationControllerTransitionStyle transitionStyle;

/// 1/2 of a second by default.
@property (nonatomic, assign) CFTimeInterval transitionDuration;

/// 24 points by default.
@property (nonatomic, strong, readonly) IBOutlet NSLayoutConstraint *navigationToolbarHostHeight;

#pragma mark - Accessing the Delegate

@property (nonatomic, weak, nullable) id<KSPNavigationControllerDelegate> delegate;

#pragma mark - Creating Navigation Controllers

- (instancetype)initWithNavigationBar:(NSView *)navigationBar rootViewController:(nullable NSViewController<KSPNavigableViewController> *)rootViewControllerOrNil NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder UNAVAILABLE_ATTRIBUTE;

#pragma mark - Accessing Items on the Navigation Stack

@property (nonatomic, strong, readonly, nullable) NSViewController<KSPNavigableViewController> *topViewController;

#pragma mark - Pushing and Popping Stack Items

- (void)setViewControllers:(NSArray<NSViewController<KSPNavigableViewController> *> *)newViewControllers animated:(BOOL)animated;

- (void)pushViewController:(NSViewController<KSPNavigableViewController> *)viewController animated:(BOOL)animated;

- (nullable NSViewController<KSPNavigableViewController> *)popViewControllerAnimated:(BOOL)animated;

- (NSArray<NSViewController<KSPNavigableViewController> *> *)popToRootViewControllerAnimated:(BOOL)animated;

- (NSArray<NSViewController<KSPNavigableViewController> *> *)popToViewController:(NSViewController<KSPNavigableViewController> *)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
