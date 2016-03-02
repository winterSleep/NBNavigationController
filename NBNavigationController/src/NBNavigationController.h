//
//  NBNavigationController.h
//  NBNavigationController
//
//  Created by Li Zhiping on 3/2/16.
//  Copyright © 2016 Li Zhiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NBNavigationController;

@protocol NBNavigationControllerDelegate <NSObject>

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(NBNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(NBNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface NBNavigationController : UIViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@property (nonatomic, copy)NSArray *viewControllers;
@property (nonatomic, readonly, strong)UIViewController *visibleViewController;

@property (nonatomic, weak) id<NBNavigationControllerDelegate> delegate;
@property (nonatomic, readonly, strong)UIViewController *topViewController;

@property (nonatomic, strong, readonly)UIGestureRecognizer *interactivePopGestureRecognizer;

@end

@interface UIViewController (NBNavigation)

- (NBNavigationController *)nb_navigationController;

@end