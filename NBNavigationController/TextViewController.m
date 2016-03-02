//
//  TextViewController.m
//  NBNavigationController
//
//  Created by Li Zhiping on 3/2/16.
//  Copyright © 2016 Li Zhiping. All rights reserved.
//

#import "TextViewController.h"
#import "NBNavigationController.h"

@implementation TextViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)push:(id)sender{
    TextViewController *vc = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"asdfasdf" style:UIBarButtonItemStyleDone target:nil action:nil]];
    [vc.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"asdfasdf" style:UIBarButtonItemStyleDone target:nil action:nil]];
    
    [vc.view setBackgroundColor:[UIColor redColor]];
    [[self nb_navigationController] pushViewController:nvc animated:YES];
}

- (IBAction)pop:(id)sender{
    [[self nb_navigationController] popViewControllerAnimated:YES];
}

@end
