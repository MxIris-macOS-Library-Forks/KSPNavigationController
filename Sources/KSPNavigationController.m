#import "KSPNavigationController+Private.h"

#import "KSPNavigationControllerDelegate.h"

#import "KSPNavigableViewController.h"

#import "KSPHitTestView.h"

#import "KSPNavigationView.h"

#import "NSView+Screenshot.h"

#import "KSPBackButton.h"

#import "NSViewController+KSPNavigationController.h"

#import <QuartzCore/CoreAnimation.h>

#import "NSBundle+Current.h"
// * * *.

typedef NS_ENUM(NSUInteger, Side)
{
    Backward,
    
    Forward
};

// * * *.

#define STANDART_SPACE 8.0

#define INVERT_SIDE(x) ((x == Backward)? Forward : Backward)

// * * *.

@implementation KSPNavigationController
{
    NSMutableArray* _viewControllers;
    
    BOOL _windowWasResizable;
}

#pragma mark - Initialization

- (instancetype) initWithNavigationBar: (NSView*) navigationBar rootViewController: (NSViewController<KSPNavigableViewController>*) rootViewControllerOrNil
{
    NSParameterAssert(navigationBar);
    
    // * * *.
    
    self = [super initWithNibName: @"KSPNavigationController" bundle: [NSBundle currentBundle]];
    
    if(!self) return nil;
    
    // * * *.
    
    _transitionStyle = KSPNavigationControllerTransitionStyleLengthy;
    
    _transitionDuration = 0.35;
    
    KSPHitTestView* const host = [[KSPHitTestView alloc] initWithFrame: NSZeroRect];
    
    host.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationBar addSubview: host];
    
    [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[host]|" options: 0 metrics: nil views: @{@"host": host}]];
    
    [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[host]|" options: 0 metrics: nil views: @{@"host": host}]];
    
    _navigationBar = host;
    
    _viewControllers = [NSMutableArray new];
    
    if(rootViewControllerOrNil)
    {
        [self setViewControllers: @[rootViewControllerOrNil] animated: NO];
    }
    
    // * * *.
    
    return self;
}

#pragma mark - NSViewController Overrides

- (instancetype) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    NSAssert(NO, @"KPNavigationController можно инициализировать только с помощью -initWithNavigationBar:rootViewController:");
    
    return nil;
}

#pragma mark - NSCoder Protocol Implementation

- (instancetype) initWithCoder: (NSCoder*) coder
{
    NSAssert(NO, @"KPNavigationController можно инициализировать только с помощью -initWithNavigationBar:rootViewController:");
    
    return nil;
}

#pragma mark -

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // * * *.
    
    self.navigationView.navigationBar = self.navigationBar;
    
    self.navigationViewPrototype = [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: self.navigationView]];
    
    // * * *.
    
    CATransition* const fadeTransition = [CATransition animation];
    
    fadeTransition.type = kCATransitionFade;
    
    fadeTransition.duration = self.transitionDuration;
    
    NSDictionary* const animations = @{@"subviews": fadeTransition};
    
    [self.navigationView.navigationBar setAnimations: animations];
    
    [self.navigationToolbarHost setAnimations: animations];
}

#pragma mark - Private Methods

- (NSButton*) newBackButtonWithTitle: (NSString*) string
{
    NSButton* const b = [[KSPBackButton alloc] initWithFrame: NSZeroRect];
    
    b.bezelStyle = NSTexturedRoundedBezelStyle;
    
    if(!string)
    {
        string = NSLocalizedStringFromTableInBundle(@"BackButtonTitle", NSStringFromClass([KSPNavigationController class]), [NSBundle currentBundle], nil);
    }
    
    b.title = string;
    
    b.action = @selector(backButtonPressed:);
    
    return b;
}

#pragma mark - Interface Callbacks

- (IBAction) backButtonPressed: (id) sender
{
    // We don't need no warnings let the motherfucker crash. Crash motherfucker.
    const SEL selector = NSSelectorFromString(@"customBackButtonAction:");
    
    if([self.topViewController respondsToSelector: selector])
    {
#pragma clang diagnostic push
        
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.topViewController performSelector: selector withObject: self];
        
#pragma clang diagnostic pop
    }
    else
    {
        [self popViewControllerAnimated: YES];
    }
}

+ (NSArray*) constraintsForVerticalFixationOfView: (NSView*) view inNavigationBar: (NSView*) navigationBar
{
    NSLayoutConstraint* const c1 = [NSLayoutConstraint constraintWithItem: view attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeCenterY multiplier: 1 constant: 0];
    
    return @[c1];
}

#pragma mark - Back button & left view

// Константы для позиции вывода с экрана.
+ (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView inNavigationBar: (NSView*) navigationBar complementaryPositionSide: (Side) side
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    // * * *.
    
    NSLayoutConstraint* const c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1 constant: STANDART_SPACE];
    
    c1.constant += ((side == Backward)? -1.0 : 1.0) * (navigationBar.bounds.size.width / 3.0);
    
    [allConstraints addObject: c1];
    
    // * * *.
    
    NSDictionary* const views = NSDictionaryOfVariableBindings(backView, leftView);
    
    NSArray* const c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c2];
    
    // * * *.
    
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: backView inNavigationBar: navigationBar]];
    
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: leftView inNavigationBar: navigationBar]];
    
    return allConstraints;
}

// Константы для рабочей позиции вида.
+ (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    // Фиксация левой стороны.
    NSLayoutConstraint* const c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1 constant: STANDART_SPACE];
    
    [allConstraints addObject: c1];
    
    // Фиксация видов между собой.
    NSDictionary* const views = NSDictionaryOfVariableBindings(backView, leftView);
    
    NSArray* const c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c2];
    
    // Фиксация правой стороны.
    if(centerView)
    {
        NSDictionary* const views = NSDictionaryOfVariableBindings(leftView, centerView);
        
        NSArray* const c3 = [NSLayoutConstraint constraintsWithVisualFormat: @"[leftView]-(>=20)-[centerView]" options: 0 metrics: nil views: views];
        
        [allConstraints addObjectsFromArray: c3];
    }
    
    // Вертикальная компонента.
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: backView inNavigationBar: navigationBar]];
    
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: leftView inNavigationBar: navigationBar]];
    
    return allConstraints;
}

+ (void) removeBackView: (NSView*) backView andLeftView: (NSView*) leftView fromNavigationBar: (NSView*) navigationBar width: (CGFloat) width slideTo: (Side) side animated: (BOOL) animated
{
    // Мы не можем вычленить нужные константы, поэтому проще выкинуть вид совсем и добавить его снова с известными константами.
    [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* const view, const NSUInteger idx, BOOL* stop)
     {
        [view removeFromSuperviewWithoutNeedingDisplay];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [navigationBar addSubview: view];
    }];
    
    // Начальное условие.
    NSArray* const startConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView utilizingCenterView: nil inNavigationBar: navigationBar];
    
    [navigationBar addConstraints: startConstraints];
    
    // Принудительно фиксируем ширину левосторонней конструкции (backView + пробел + leftView).
    [navigationBar addConstraint: [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeft relatedBy: NSLayoutRelationEqual toItem: leftView attribute: NSLayoutAttributeRight multiplier: 1 constant: -width]];
    
    // Тут надо какой-то перерасчет.
    [navigationBar layoutSubtreeIfNeeded];
    
    // Выкидываем временную константу.
    [navigationBar removeConstraints: startConstraints];
    
    // Окончательное условие.
    NSArray* const finishConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView inNavigationBar: navigationBar complementaryPositionSide: side];
    
    [navigationBar addConstraints: finishConstraints];
    
    // Сама анимация.
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationBar layoutSubtreeIfNeeded];
        
        [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* const view, const NSUInteger idx, BOOL* stop)
         {
            view.alphaValue = 0;
        }];
    }
                        completionHandler: ^
     {
        [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* const view, const NSUInteger idx, BOOL* stop)
         {
            [view removeFromSuperviewWithoutNeedingDisplay];
        }];
    }];
}

+ (void) insertBackView: (NSView*) backView andLeftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
    [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* const view, const NSUInteger idx, BOOL* stop)
     {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [navigationBar addSubview: view];
        
        view.alphaValue = 0;
    }];
    
    // Начальное условие.
    NSArray* const startConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView inNavigationBar: navigationBar complementaryPositionSide: INVERT_SIDE(side)];
    
    [navigationBar addConstraints: startConstraints];
    
    // Тут надо какой-то перерасчет.
    [navigationBar layoutSubtreeIfNeeded];
    
    // Выкидываем временную константу.
    [navigationBar removeConstraints: startConstraints];
    
    // Окончательное условие.
    NSArray* const finishConstraints = [self constraintsForBackView: backView andLeftView: leftView utilizingCenterView: centerView inNavigationBar: navigationBar];
    
    [navigationBar addConstraints: finishConstraints];
    
    // Сама анимация.
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationBar layoutSubtreeIfNeeded];
        
        [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* const view, const NSUInteger idx, BOOL* stop)
         {
            view.alphaValue = 1;
        }];
    }
                        completionHandler: ^
     {
    }];
}

#pragma mark - Center view

// Константы для позиции вывода с экрана.
+ (NSArray*) constraintsForCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar complementaryPositionSide: (Side) side
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    NSDictionary* const views = NSDictionaryOfVariableBindings(navigationBar, centerView);
    
    NSString* const format = ((side == Backward)? @"[centerView][navigationBar]" : @"[navigationBar][centerView]");
    
    NSArray* const c1 = [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c1];
    
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: centerView inNavigationBar: navigationBar]];
    
    return allConstraints;
}

// Константы для рабочей позиции вида.
+ (NSArray*) constraintsForCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    NSLayoutConstraint* const c1 = [NSLayoutConstraint constraintWithItem: centerView attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeCenterX multiplier: 1 constant: 0];
    
    // Центральный вид стремится к середине, но, при необходимости, может быть расположен ассиметрично.
    c1.priority = 10;
    
    [allConstraints addObject: c1];
    
    [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfView: centerView inNavigationBar: navigationBar]];
    
    return allConstraints;
}

+ (void) removeCenterView: (NSView*) centerView fromNavigationBar: (NSView*) navigationBar x: (CGFloat) x width: (CGFloat) width slideTo: (Side) side animated: (BOOL) animated
{
    // Мы не можем вычленить нужные константы, поэтому проще выкинуть вид совсем и добавить его снова с известными константами.
    [centerView removeFromSuperviewWithoutNeedingDisplay];
    
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationBar addSubview: centerView];
    
    // Начальное условие.
    NSArray* startConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar];
    
    // Принудительно фиксируем левый край центральной плашки.
    id const c = [NSLayoutConstraint constraintWithItem: centerView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1 constant: x];
    
    startConstraints = [startConstraints arrayByAddingObject: c];
    
    // * * *.
    
    [navigationBar addConstraints: startConstraints];
    
    // Принудительно фиксируем ширину центральной плашки.
    NSDictionary* const metrics = @{@"currentWidth": @(width)};
    
    NSDictionary* const views = NSDictionaryOfVariableBindings(centerView);
    
    [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"[centerView(==currentWidth)]" options: 0 metrics: metrics views: views]];
    
    // Тут надо какой-то перерасчет.
    [navigationBar layoutSubtreeIfNeeded];
    
    // Выкидываем временную константу.
    [navigationBar removeConstraints: startConstraints];
    
    // Окончательное условие.
    NSArray* const finishConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar complementaryPositionSide: side];
    
    [navigationBar addConstraints: finishConstraints];
    
    // Сама анимация.
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationBar layoutSubtreeIfNeeded];
        
        centerView.alphaValue = 0;
    }
                        completionHandler: ^
     {
        [centerView removeFromSuperviewWithoutNeedingDisplay];
    }];
}

+ (void) insertCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationBar addSubview: centerView];
    
    // Начальное условие.
    centerView.alphaValue = 0;
    
    NSArray* const startConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar complementaryPositionSide: INVERT_SIDE(side)];
    
    [navigationBar addConstraints: startConstraints];
    
    // Тут надо какой-то перерасчет.
    [navigationBar layoutSubtreeIfNeeded];
    
    // Выкидываем временную константу.
    [navigationBar removeConstraints: startConstraints];
    
    // Окончательное условие.
    NSArray* const finishConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar];
    
    [navigationBar addConstraints: finishConstraints];
    
    // Сама анимация.
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationBar layoutSubtreeIfNeeded];
        
        centerView.alphaValue = 1;
    }
                        completionHandler: ^
     {
    }];
}

#pragma mark - Right view

+ (NSArray*) constraintsForRightView: (NSView*) rightView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    // Фиксация левой стороны.
    NSLayoutConstraint* const c1 = [NSLayoutConstraint constraintWithItem: rightView attribute: NSLayoutAttributeTrailing relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeTrailing multiplier: 1 constant: -STANDART_SPACE];
    
    [allConstraints addObject: c1];
    
    // Фиксация правой стороны.
    if(centerView)
    {
        NSDictionary* const views = NSDictionaryOfVariableBindings(centerView, rightView);
        
        NSArray* const c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[centerView]-(>=20)-[rightView]" options: 0 metrics: nil views: views];
        
        [allConstraints addObjectsFromArray: c2];
    }
    
    // Вертикальная компонента.
    [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: rightView inNavigationBar: navigationBar]];
    
    return allConstraints;
}

+ (void) removeRightView: (NSView*) rightView fromNavigationBar: (NSView*) navigationBar width: (CGFloat) width animated: (BOOL) animated
{
    // Принудительно фиксируем ширину rightView.
    NSDictionary* const metrics = @{@"currentWidth": @(width)};
    
    NSDictionary* const views = NSDictionaryOfVariableBindings(rightView);
    
    [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"[rightView(==currentWidth)]" options: 0 metrics: metrics views: views]];
    
    // * * *.
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        rightView.alphaValue = 0;
    }
                        completionHandler: ^
     {
        [rightView removeFromSuperviewWithoutNeedingDisplay];
    }];
}

+ (void) insertRightView: (NSView*) rightView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar animated: (BOOL) animated
{
    rightView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationBar addSubview: rightView];
    
    // Окончательное условие.
    rightView.alphaValue = 0;
    
    NSArray* const constraints = [[self class] constraintsForRightView: rightView utilizingCenterView: centerView inNavigationBar: navigationBar];
    
    [navigationBar addConstraints: constraints];
    
    [navigationBar layoutSubtreeIfNeeded];
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        rightView.alphaValue = 1;
    }
                        completionHandler: ^
     {
    }];
}

#pragma mark - Measurement

+ (NSSize) fittingSizeForNavigationBarOfNavViewController: (NSViewController<KSPNavigableViewController>*) viewController
{
    NSView* const imaginaryNavigationBar = [[NSView alloc] initWithFrame: NSZeroRect];
    
    imaginaryNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center Navigation Bar View.
    [self insertCenterView: viewController.centerNavigationBarView inNavigationBar: imaginaryNavigationBar slideTo: Forward animated: NO];
    
    // Back Navigation Bar Button & Left Navigation Bar View.
    [self insertBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: imaginaryNavigationBar slideTo: Forward animated: NO];
    
    // Right Navigation Bar View.
    [self insertRightView: viewController.rightNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: imaginaryNavigationBar animated: NO];
    
    return imaginaryNavigationBar.fittingSize;
}

#pragma mark - Main view

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView complementaryPositionSide: (Side) side transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    // Переменные для биндингов форматной строки.
    NSView* const navigationBar = navigationView.navigationBar;
    
    NSView* const navigationToolbarHost = navigationView.navigationToolbarHost;
    
    NSDictionary* const views = NSDictionaryOfVariableBindings(navigationView, navigationBar, mainView, navigationToolbarHost);
    
    if(side == Forward)
    {
        id const c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[navigationView][mainView(==navigationView)]" options: 0 metrics: nil views: views];
        
        [allConstraints addObjectsFromArray: c];
    }
    else
    {
        id const c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[mainView(==navigationView)]" options: 0 metrics: nil views: views];
        
        [allConstraints addObjectsFromArray: c];
        
        const CGFloat m = ((transitionStyle == KSPNavigationControllerTransitionStyleLengthy)? 1 : 3);
        
        id const c2 = [NSLayoutConstraint constraintWithItem: mainView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationView attribute: NSLayoutAttributeLeading multiplier: 1 constant: -(navigationView.frame.size.width / m)];
        
        [allConstraints addObject: c2];
    }
    
    // * * *.
    
    NSArray* const vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[mainView][navigationToolbarHost]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: vertical];
    
    return allConstraints;
}

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView
{
    NSMutableArray* const allConstraints = [NSMutableArray new];
    
    // * * *.
    
    NSDictionary* const views1 = NSDictionaryOfVariableBindings(mainView);
    
    NSArray* const horizontal = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[mainView]|" options: 0 metrics: nil views: views1];
    
    [allConstraints addObjectsFromArray: horizontal];
    
    // * * *.
    
    // Переменные для биндингов форматной строки.
    NSView* const navigationBar = navigationView.navigationBar;
    
    NSView* const navigationToolbarHost = navigationView.navigationToolbarHost;
    
    NSDictionary* const views2 = NSDictionaryOfVariableBindings(navigationBar, mainView, navigationToolbarHost);
    
    NSArray* const vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[mainView][navigationToolbarHost]" options: 0 metrics: nil views: views2];
    
    [allConstraints addObjectsFromArray: vertical];
    
    return allConstraints;
}

+ (void) removeMainView: (NSView*) mainView fromNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
    [mainView removeFromSuperviewWithoutNeedingDisplay];
    
    // * * *.
    
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationView addSubview: mainView];
    
    // * * *.
    
    NSArray* const startConstraints = [[self class] constraintsForMainView: mainView inNavigationView: navigationView];
    
    [navigationView addConstraints: startConstraints];
    
    [navigationView layoutSubtreeIfNeeded];
    
    [navigationView removeConstraints: startConstraints];
    
    // * * *.
    
    NSArray* const finishConstraints = [[self class] constraintsForMainView: mainView inNavigationView: navigationView complementaryPositionSide: side transitionStyle: transitionStyle];
    
    [navigationView addConstraints: finishConstraints];
    
    // * * *.
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationView layoutSubtreeIfNeeded];
    }
                        completionHandler: ^
     {
        [mainView removeFromSuperview];
    }];
}

+ (void) insertMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationView addSubview: mainView positioned: ((side == Forward)? NSWindowBelow : NSWindowAbove) relativeTo: nil];
    
    // * * *.
    
    NSArray* const startConstraints = [[self class] constraintsForMainView: mainView inNavigationView: navigationView complementaryPositionSide: INVERT_SIDE(side) transitionStyle: transitionStyle];
    
    [navigationView addConstraints: startConstraints];
    
    [navigationView layoutSubtreeIfNeeded];
    
    [navigationView removeConstraints: startConstraints];
    
    // * * *.
    
    NSArray* const finishConstraints = [[self class] constraintsForMainView: mainView inNavigationView: navigationView];
    
    [navigationView addConstraints: finishConstraints];
    
    // * * *.
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
     {
        context.allowsImplicitAnimation = YES;
        
        [navigationView layoutSubtreeIfNeeded];
    }
                        completionHandler: ^
     {
    }];
}

#pragma mark - Navigation toolbar

+ (NSArray*) constraintsForNavigationToolbar: (NSView*) navigationToolbar
{
    NSMutableArray* const allConstraints = [NSMutableArray array];
    
    NSDictionary* const dict = NSDictionaryOfVariableBindings(navigationToolbar);
    
    [allConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[navigationToolbar]|" options: 0 metrics: nil views: dict]];
    
    [allConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[navigationToolbar]|" options: 0 metrics: nil views: dict]];
    
    return allConstraints;
}

+ (void) removeNavigationToolbar: (NSView*) navigationToolbar
{
    [navigationToolbar removeFromSuperview];
}

+ (void) insertNavigationToolbar: (NSView*) navigationToolbar inNavigationToolbarHost: (NSView*) navigationToolbarHost
{
    navigationToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [navigationToolbarHost addSubview: navigationToolbar];
    
    [navigationToolbarHost addConstraints: [self constraintsForNavigationToolbar: navigationToolbar]];
}

#pragma mark - Ядровой метод

+ (void) removeViewController: (NSViewController<KSPNavigableViewController>*) viewController fromNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
    /* Рассчитываем текущую ширину всех вьюшек на навигационной плашке. */
    
    // Запоминаем текущую ширину всей левосторонней конструкции (backView + пробел + leftView).
    const CGFloat backPlusLeftWidth = viewController.leftNavigationBarView.frame.origin.x + viewController.leftNavigationBarView.frame.size.width - viewController.backButton.frame.origin.x;
    
    // Запоминаем текущую ширину центральной плашки.
    const CGFloat centerWidth = viewController.centerNavigationBarView.frame.size.width;
    
    const CGFloat centerX = viewController.centerNavigationBarView.frame.origin.x;
    
    // Запоминаем текущую ширину rightView.
    const CGFloat rightWidth = viewController.rightNavigationBarView.frame.size.width;
    
    /* Back Navigation Bar Button & Left Navigation Bar View. */
    [self removeBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView fromNavigationBar: navigationView.navigationBar width: backPlusLeftWidth slideTo: side animated: animated];
    
    /* Center Navigation Bar View. */
    [self removeCenterView: viewController.centerNavigationBarView fromNavigationBar: navigationView.navigationBar x: centerX width: centerWidth slideTo: side animated: animated];
    
    /* Right Navigation Bar View. */
    [self removeRightView: viewController.rightNavigationBarView fromNavigationBar: navigationView.navigationBar width: rightWidth animated: animated];
    
    /* Main View. */
    [self removeMainView: viewController.view fromNavigationView: navigationView slideTo: side animated: animated transitionStyle: transitionStyle];
    
    /* Navigation Toolbar. */
    [self removeNavigationToolbar: viewController.navigationToolbar];
}

+ (void) insertViewController: (NSViewController<KSPNavigableViewController>*) viewController inNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
    /* Center Navigation Bar View. */
    [self insertCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
    
    /* Back Navigation Bar Button & Left Navigation Bar View. */
    [self insertBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
    
    /* Right Navigation Bar View. */
    [self insertRightView: viewController.rightNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar animated: animated];
    
    /* Main View. */
    [self insertMainView: viewController.view inNavigationView: navigationView slideTo: side animated: animated transitionStyle: transitionStyle];
    
    /* Navigation Toolbar. */
    [self insertNavigationToolbar: viewController.navigationToolbar inNavigationToolbarHost: navigationView.navigationToolbarHost];
}

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceNavViewController: (NSViewController<KSPNavigableViewController>*) oldControllerOrNil with: (NSViewController<KSPNavigableViewController>*) newController animated: (BOOL) animated slideTo: (Side) side
{
    NSParameterAssert(newController);
    
    // Подгружаем вид контроллера навигации.
    if(!self.view) [self loadView];
    
    // Вид контроллера навигации перестает реагировать на клики.
    if(animated)
    {
        self.navigationBar.rejectHitTest = YES;
        
        ((KSPHitTestView*)self.view).rejectHitTest = YES;
    }
    
    // * * *.
    
    {{ /* Готовим кнопку «Назад» */
        NSButton* backButtonNew = nil;
        
        if(_viewControllers.count > 1)
        {
            NSString* const title = ((NSViewController<KSPNavigableViewController>*)_viewControllers[_viewControllers.count - 2]).title;
            
            backButtonNew = [self newBackButtonWithTitle: title];
        }
        else
        {
            backButtonNew = [[NSButton alloc] initWithFrame: NSZeroRect];
            
            NSDictionary* const views = NSDictionaryOfVariableBindings(backButtonNew);
            
            [backButtonNew addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[backButtonNew(==0@1000)]" options: 0 metrics: nil views: views]];
        }
        
        backButtonNew.target = self;
        
        newController.backButton = backButtonNew;
    }}
    
    // * * *.
    
    (void)newController.view;
    
    const NSSize fittingSize = [[self class] fittingSizeForNavigationBarOfNavViewController: newController];
    
    const BOOL shouldResize = (fittingSize.width > self.view.frame.size.width);
    
    void (^actualNavigationTransition)(void) = ^()
    {
        _windowWasResizable = (self.view.window.styleMask & NSWindowStyleMaskResizable);
        
        if(_windowWasResizable)
        {
            // Размер окна с навигационным контроллером больше не может быть изменен.
            [self.view.window setStyleMask: ([self.view.window styleMask] & ~NSWindowStyleMaskResizable)];
        }
        
        // * * *.
        
        if([self.delegate respondsToSelector: @selector(navigationController:willShowViewController:animated:)])
        {
            [self.delegate navigationController: self willShowViewController: newController animated: animated];
        }
        
        if ([oldControllerOrNil respondsToSelector:@selector(navigationViewWillDisappear:)]) {
            [oldControllerOrNil navigationViewWillDisappear: animated];
        }
        
        if ([newController respondsToSelector:@selector(navigationViewWillAppear:)]) {
            [newController navigationViewWillAppear: animated];
        }
        
        
        
        (void)newController.view;
        
        // * * *.
        
        // Анимация смены главного вида.
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
         {
            context.duration = (animated? self.transitionDuration : 0);
            
            [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
            
            if(oldControllerOrNil)
            {
                [[self class] removeViewController: oldControllerOrNil fromNavigationView: self.navigationView slideTo: side animated: animated transitionStyle: self.transitionStyle];
            }
            
            [[self class] insertViewController: newController inNavigationView: self.navigationView slideTo: side animated: animated transitionStyle: self.transitionStyle];
        }
                            completionHandler: ^
         {
            if ([oldControllerOrNil respondsToSelector:@selector(navigationViewDidDisappear:)]) {
                [oldControllerOrNil navigationViewDidDisappear: animated];
            }
            
            if ([newController respondsToSelector:@selector(navigationViewDidAppear:)]) {
                [newController navigationViewDidAppear: animated];
            }
            
            
            if([self.delegate respondsToSelector: @selector(navigationController:didShowViewController:animated:)])
            {
                [self.delegate navigationController: self didShowViewController: newController animated: animated];
            }
            
            if(_windowWasResizable)
            {
                // Окно снова можно ресайзить.
                [self.view.window setStyleMask: (self.view.window.styleMask | NSWindowStyleMaskResizable)];
            }
            
            // Навигационный вид снова реагирует на клики.
            ((KSPHitTestView*)self.view).rejectHitTest = NO;
            
            self.navigationBar.rejectHitTest = NO;
            
            // Ставим фокус на нужный контрол.
            [self.view.window makeFirstResponder: self.topViewController.proposedFirstResponder];
        }];
    };
    
    // * * *.
    
    if(shouldResize)
    {
        NSLayoutConstraint* const constraint = [NSLayoutConstraint constraintWithItem: self.navigationBar attribute:NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem: nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1 constant: self.view.frame.size.width];
        
        [self.navigationBar addConstraint: constraint];
        
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* const context)
         {
            context.duration = (animated? (1.0 / 3.0) : 0);
            
            context.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            
            [constraint animator].constant = fittingSize.width;
        }
                            completionHandler: ^
         {
            [self.navigationBar removeConstraint: constraint];
            
            actualNavigationTransition();
        }];
    }
    else
    {
        actualNavigationTransition();
    }
}

#pragma mark - Public Methods

// Replaces the view controllers currently managed by the navigation controller with the specified items.
- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated
{
    NSParameterAssert(newViewControllers);
    
    NSAssert(newViewControllers.count > 0, @"Unable to set void view controllers array.");
    
    // * * *.
    
    NSViewController<KSPNavigableViewController>* const current = self.topViewController;
    
    [_viewControllers removeAllObjects];
    
    [_viewControllers addObjectsFromArray: newViewControllers];
    
    [_viewControllers makeObjectsPerformSelector: @selector(setNavigationController:) withObject: self];
    
    self.topViewController = _viewControllers.lastObject;
    
    [self replaceNavViewController: current with: newViewControllers.lastObject animated: animated slideTo: Backward];
}

// Pushes a view controller onto the receiver’s stack and updates the display.
- (void) pushViewController: (NSViewController<KSPNavigableViewController>*) viewController animated: (BOOL) animated
{
    NSParameterAssert(viewController);
    
    NSAssert(![_viewControllers containsObject: viewController], @"View controller already on the stack.");
    
    // * * *.
    
    NSViewController<KSPNavigableViewController>* const current = self.topViewController;
    
    [_viewControllers addObject: viewController];
    
    [viewController setNavigationController: self];
    
    self.topViewController = viewController;
    
    [self replaceNavViewController: current with: viewController animated: animated slideTo: Backward];
}

// Pops the top view controller from the navigation stack and updates the display.
- (NSViewController<KSPNavigableViewController>*) popViewControllerAnimated: (BOOL) animated
{
    NSInteger controllersCount = _viewControllers.count;
    
    // Если на стеке только корневой контроллер - ничего не делаем.
    if(controllersCount < 2) return nil;
    
    NSArray* const poppedControllers = [self popToViewController: _viewControllers[controllersCount - 2] animated: animated];
    
    return poppedControllers.lastObject;
}

// Pops all the view controllers on the stack except the root view controller and updates the display.
- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated
{
    // Если на стеке только корневой контроллер - ничего не делаем.
    if(_viewControllers.count < 2) return @[];
    
    return [self popToViewController: _viewControllers[0] animated: animated];
}

// Pops view controllers until the specified view controller is at the top of the navigation stack.
- (NSArray*) popToViewController: (NSViewController<KSPNavigableViewController>*) viewController animated: (BOOL) animated
{
    NSParameterAssert(viewController);
    
    NSAssert([_viewControllers containsObject: viewController], @"View controller not on the stack.");
    
    // * * *.
    
    if(viewController == self.topViewController) return @[];
    
    NSViewController<KSPNavigableViewController>* const current = self.topViewController;
    
    const NSUInteger indexOfViewController = [_viewControllers indexOfObject: viewController];
    
    // Сохраняем катапультированные контроллеры.
    const NSRange ejectedRange = NSMakeRange(indexOfViewController + 1, _viewControllers.count - indexOfViewController - 1);
    
    NSArray* const ejectedControllers = [_viewControllers subarrayWithRange: ejectedRange];
    
    [_viewControllers removeObjectsInRange: ejectedRange];
    
    self.topViewController = viewController;
    
    [self replaceNavViewController: current with: viewController animated: animated slideTo: Forward];
    
    return ejectedControllers;
}

@end
