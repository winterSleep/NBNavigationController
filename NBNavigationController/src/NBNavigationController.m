//
//  NBNavigationController.m
//  NBNavigationController
//
//  Created by Li Zhiping on 3/2/16.
//  Copyright © 2016 Li Zhiping. All rights reserved.
//

#import "NBNavigationController.h"

#define boundsWidth self.view.bounds.size.width
#define boundsHeight self.view.bounds.size.height

CGFloat const NBPanVelocityXAnimationThreshold = 400.0f;

@interface NBNavigationController ()

@property (strong, nonatomic) UIGestureRecognizer *interactivePopGestureRecognizer;
@property (assign, nonatomic)BOOL isSwipingBack;

@end

@implementation NBNavigationController {
    UIViewController *_visibleViewController;
    BOOL _needsDeferredUpdate;
    BOOL _isUpdating;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if ((self=[super initWithNibName:nil bundle:nil])) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    self.interactivePopGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(popGestureAction:)];
    [self.interactivePopGestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:self.interactivePopGestureRecognizer];
    
    CGRect contentRect = self.view.bounds;
    _visibleViewController.view.frame = contentRect;
    _visibleViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_visibleViewController.view];
}

- (UIViewController *)previousViewController{
    NSInteger index = self.viewControllers.count - 2;
    if (index >= 0) {
        UIViewController *previousViewController = [self.viewControllers objectAtIndex:index];
        return previousViewController;
    }
    return nil;
}

- (void)popGestureAction:(UIPanGestureRecognizer *)gesture{
    if ([self.viewControllers count] > 1) {
        CGPoint translation = [gesture translationInView:self.view];
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self startPopView];
        }else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded){
            [self endPopSnapShotView:gesture];
        }else if (gesture.state == UIGestureRecognizerStateChanged){
            [self popSnapShotViewWithPanGestureDistance:translation.x];
        }
    }
}

- (void)startPopView{
    
    self.isSwipingBack = YES;
    
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    //add shadows just like UINavigationController
    self.visibleViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.visibleViewController.view.layer.shadowOffset = CGSizeMake(3, 3);
    self.visibleViewController.view.layer.shadowRadius = 5;
    self.visibleViewController.view.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.visibleViewController.view.center = center;
    
    UIViewController *previousViewController = [self previousViewController];
    center.x -= 60;
    previousViewController.view.center = center;
    previousViewController.view.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view insertSubview:previousViewController.view
                belowSubview:self.visibleViewController.view];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    
    self.visibleViewController.view.center = currentSnapshotViewCenter;
    [[self previousViewController] view].center = prevSnapshotViewCenter;
}

-(void)endPopSnapShotView:(UIPanGestureRecognizer *)gesture{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    CGPoint velocity = [gesture velocityInView:self.view];
    
    if (self.visibleViewController.view.center.x >= boundsWidth ||
        velocity.x > NBPanVelocityXAnimationThreshold) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.visibleViewController.view.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            [[self previousViewController] view].center = CGPointMake(boundsWidth/2, boundsHeight/2);
        }completion:^(BOOL finished) {
            [self popViewControllerAnimated:NO];
            self.view.userInteractionEnabled = YES;
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.visibleViewController.view.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            [[self previousViewController] view].center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
        }completion:^(BOOL finished) {
            [[[self previousViewController] view] removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            self.isSwipingBack = NO;
        }];
    }
}

- (void)dealloc
{
    
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)_setNeedsDeferredUpdate
{
    _needsDeferredUpdate = YES;
    [self.view setNeedsLayout];
}

- (void)_updateVisibleViewController:(BOOL)animated
{
    _isUpdating = YES;
    
    UIViewController *newVisibleViewController = self.topViewController;
    UIViewController *oldVisibleViewController = _visibleViewController;
    
    const BOOL isPushing = (oldVisibleViewController.parentViewController != nil);
    
    [oldVisibleViewController beginAppearanceTransition:NO animated:animated];
    [newVisibleViewController beginAppearanceTransition:YES animated:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.delegate navigationController:self willShowViewController:newVisibleViewController animated:animated];
    }
    
    _visibleViewController = newVisibleViewController;
    
    const CGRect bounds = self.view.bounds;
    CGRect contentRect = bounds;
    
    newVisibleViewController.view.transform = CGAffineTransformIdentity;
    newVisibleViewController.view.frame = contentRect;
    
    CGAffineTransform inStartTransform = isPushing? CGAffineTransformMakeTranslation(bounds.size.width, 0) : CGAffineTransformMakeTranslation(-bounds.size.width, 0);
    CGAffineTransform outEndTransform = isPushing? CGAffineTransformMakeTranslation(-bounds.size.width, 0) : CGAffineTransformMakeTranslation(bounds.size.width, 0);
    if (!animated) {
        inStartTransform = CGAffineTransformIdentity;
        outEndTransform = CGAffineTransformIdentity;
    }
    
    newVisibleViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:newVisibleViewController.view atIndex:0];
    newVisibleViewController.view.transform = inStartTransform;
    
    [UIView animateWithDuration:animated? 0.33 : 0
                     animations:^{
                         oldVisibleViewController.view.transform = outEndTransform;
                         newVisibleViewController.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [oldVisibleViewController.view removeFromSuperview];
                         
                         [oldVisibleViewController endAppearanceTransition];
                         [newVisibleViewController endAppearanceTransition];
                         
                         // not sure if this is safe or not, really, but the real one must do something along these lines?
                         // it could perform this check in a variety of ways, though, with subtly different results so I'm
                         // not sure what's best. this seemed generally safest.
                         if (oldVisibleViewController && isPushing) {
                             [oldVisibleViewController didMoveToParentViewController:nil];
                         } else {
                             [newVisibleViewController didMoveToParentViewController:self];
                         }
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
                             [self.delegate navigationController:self didShowViewController:newVisibleViewController animated:animated];
                         }
                     }];
    _isUpdating = NO;
}

- (void)viewWillLayoutSubviews
{
    if (_needsDeferredUpdate) {
        _needsDeferredUpdate = NO;
        [self _updateVisibleViewController:NO];
    }
}

- (NSArray *)viewControllers
{
    return [self.childViewControllers copy];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
    assert([newViewControllers count] >= 1);
    
    if (![newViewControllers isEqualToArray:self.viewControllers]) {
        // find the controllers we used to have that we won't be using anymore
        NSMutableArray *removeViewControllers = [self.viewControllers mutableCopy];
        [removeViewControllers removeObjectsInArray:newViewControllers];
        
        // these view controllers are not in the new collection, so we must remove them as children
        // I'm pretty sure the real UIKit doesn't attempt to be so clever..
        for (UIViewController *controller in removeViewControllers) {
            [controller willMoveToParentViewController:nil];
            [controller removeFromParentViewController];
        }
        
        // add them back in one-by-one and only apply animation to the last one (if any)
        for (UIViewController *controller in newViewControllers) {
            [self pushViewController:controller animated:(animated && (controller == [newViewControllers lastObject]))];
        }
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
    [self setViewControllers:newViewControllers animated:NO];
}

- (UIViewController *)topViewController
{
    return [self.childViewControllers lastObject];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    assert(![viewController isKindOfClass:[UITabBarController class]]);
    assert(![self.viewControllers containsObject:viewController]);
    assert(viewController.parentViewController == nil || viewController.parentViewController == self);
    
    if (viewController.parentViewController != self) {
        [self addChildViewController:viewController];
    }
    
    if (animated) {
        [self _updateVisibleViewController:animated];
    } else {
        [self _setNeedsDeferredUpdate];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    // don't allow popping the rootViewController
    if ([self.viewControllers count] <= 1) {
        return nil;
    }
    
    UIViewController *formerTopViewController = self.topViewController;
    
    if (formerTopViewController == _visibleViewController) {
        [formerTopViewController willMoveToParentViewController:nil];
    }
    
    // the real thing seems to cheat here and removes the parent immediately even if animated
    [formerTopViewController removeFromParentViewController];
    
    if (animated) {
        [self _updateVisibleViewController:animated];
    } else {
        [self _setNeedsDeferredUpdate];
    }
    
    return formerTopViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSMutableArray *popped = [[NSMutableArray alloc] init];
    
    if ([self.viewControllers containsObject:viewController]) {
        while (self.topViewController != viewController) {
            UIViewController *poppedController = [self popViewControllerAnimated:animated];
            if (poppedController) {
                [popped addObject:poppedController];
            } else {
                break;
            }
        }
    }
    
    return popped;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

- (void)setContentSizeForViewInPopover:(CGSize)newSize
{
    self.topViewController.contentSizeForViewInPopover = newSize;
}

- (UIViewController *)defaultResponderChildViewController
{
    return self.topViewController;
}

@end

@implementation UIViewController (NBNavigation)

- (NBNavigationController *)nb_navigationController{
    return [self _nearestParentViewControllerThatIsKindOf:[NBNavigationController class]];
}

- (id)_nearestParentViewControllerThatIsKindOf:(Class)c
{
    UIViewController *controller = [self parentViewController];
    while (controller && ![controller isKindOfClass:c]) {
        controller = [controller parentViewController];
    }
    return controller;
}

@end