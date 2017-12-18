//
//  GitHub:https://github.com/zhuozhuo

//  博客：http://www.jianshu.com/users/39fb9b0b93d3/latest_articles

//  欢迎投稿分享：http://www.jianshu.com/collection/4cd59f940b02

//
//  Created by aimoke on 16/10/28.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "NavigationViewController.h"
#import <objc/runtime.h>

@interface NavigationViewController ()

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self customNavigationbarBottomColorMethods2];
    
}

-(void)customNavigationbarBottomColorMethods1
{
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0.5)]];
    
}

-(void)customNavigationbarBottomColorMethods2
{
    //先查看View层次结构
    NSLog(@"Navigationbar recursiveDescription:\n%@",[self.navigationBar performSelector:@selector(recursiveDescription)]);
    
    //打印完后我们发现有个高度为0.5的UIImageView 类型 SuperView type为 _UIBarBackground的视图
    //遍历navigationBar 属性
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self.navigationBar class], &outCount);
    for (NSInteger i = 0; i < outCount; ++i) {
        Ivar ivar = *(ivars + i);
        NSLog(@"navigationBar Propertys:\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
    }
    free(ivars);
    
    //遍历结果可以发现navigationbar 中的type 为_UIBarBackground 名称为 _barBackgroundView
    //遍历_barBackgroundView 中的属性
    unsigned int viewOutCount = 0;
    CGFloat sysytemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    
    NSLog(@"version:%f",sysytemVersion);
    UIView *barBackgroundView = nil;
    /*iOS 10.0+为`_barBackgroundView`,小于iOS10.0这个属性名称为`_UIBarBackground`.*/
    if (sysytemVersion<10.0) {
        barBackgroundView = [self.navigationBar valueForKey:@"_backgroundView"];
    }else if(sysytemVersion >=10.0 && sysytemVersion < 11){
        barBackgroundView = [self.navigationBar valueForKey:@"_barBackgroundView"];
    }else{ //>11
       
    }
    if (barBackgroundView) {
        Ivar *viewivars = class_copyIvarList([barBackgroundView class], &viewOutCount);
        for (NSInteger i = 0; i < viewOutCount; ++i) {
            Ivar ivar = *(viewivars + i);
            NSLog(@"_barBackgroundView Propertys:\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
        }
        free(viewivars);
        
        //找到type为 UIImageView 的属性有_shadowView,_backgroundImageView。因为底部线条可以设置shadowImage，所有我们猜测是_shadowView
        UIImageView *navigationbarLineView = [barBackgroundView valueForKey:@"_shadowView"];
        if (navigationbarLineView && [navigationbarLineView isKindOfClass:[UIImageView class]]) {
            UIView *lineView = [[UIView alloc]init];
            lineView.backgroundColor = [UIColor redColor];
            lineView.translatesAutoresizingMaskIntoConstraints = NO;
            [navigationbarLineView addSubview:lineView];
            
            //这里我们要用约束不然旋转后有问题
            [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
            
            [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            
            [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            
            [navigationbarLineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navigationbarLineView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        }
    }else{
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor redColor];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.navigationBar addSubview:lineView];
        
        UIView *superView = self.navigationBar;
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [lineView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1]];
    }
    
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - public methods
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
