#import <AppKit/AppKit.h>

@class KSPNavigationController;

NS_ASSUME_NONNULL_BEGIN

@protocol KSPNavigableViewController <NSObject>

@property (readwrite, weak, nonatomic, nullable) KSPNavigationController *navigationController;

@property (readwrite, strong, nonatomic, nullable) NSButton *backButton;

@property (readwrite, strong, nonatomic, nullable) NSView *leftNavigationBarView;

@property (readwrite, strong, nonatomic, nullable) NSView *centerNavigationBarView;

@property (readwrite, strong, nonatomic, nullable) NSView *rightNavigationBarView;

@property (readwrite, strong, nonatomic, nullable) NSView *navigationToolbar;

@optional

- (void)navigationViewWillAppear:(BOOL)animated;

- (void)navigationViewDidAppear:(BOOL)animated;

- (void)navigationViewWillDisappear:(BOOL)animated;

- (void)navigationViewDidDisappear:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
