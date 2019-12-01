//
//  ViewController.m
//  Tetris
//
//  Created by master on 30.12.17.
//  Copyright © 2017 l. All rights reserved.
//

#import "ViewController.h"
#import "TetrisView.h"
@interface ViewController ()

@end

@implementation ViewController
{
    TetrisView *tetrisView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self->tetrisView = [[TetrisView alloc] initWithFrame:self.view.frame];
    self.view  = self->tetrisView;
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
