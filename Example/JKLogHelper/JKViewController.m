//
//  JKViewController.m
//  JKLogHelper
//
//  Created by xindizhiyin2014 on 06/20/2019.
//  Copyright (c) 2019 xindizhiyin2014. All rights reserved.
//

#import "JKViewController.h"
#import <JKLogHelper/JKLogHelper.h>

@interface JKViewController ()

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"AAA");
    NSLog(@"BBB");
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)tap:(UITapGestureRecognizer *)tap{
    NSLog(@"ccc %@",[NSDate date]);
}

- (void)longPress:(UILongPressGestureRecognizer *)longpress{
    [JKLogHelper viewLog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
