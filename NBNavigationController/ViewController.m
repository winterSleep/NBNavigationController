//
//  ViewController.m
//  NBNavigationController
//
//  Created by Li Zhiping on 3/2/16.
//  Copyright © 2016 Li Zhiping. All rights reserved.
//

#import "ViewController.h"
#import "NBNavigationController.h"
#import "TextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)popAction:(id)sender{
    TextViewController *vc = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    NBNavigationController *nvc = [[NBNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
