
[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0.5)]];

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
```
> 此方法是现在大部分博客中有介绍的，不过有缺陷。如果 `self.navigationBar.translucent = YES;`则`navigationbar`透明了。有时我们又不得不设`self.navigationBar.translucent = YES;`例如使用`UISearchController`做通讯录时。其中的坑可以看我这篇博文介绍[iOS navigationBar translucent 属性](http://www.jianshu.com/p/5271c51e0b98)。

### 方法二

> 此方法是我推荐的一种，详情请看代码及代码注释。

1. 首先导入头文件 `#import <objc/runtime.h>`

2. 代码展示

```objective-c
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
    UIView *barBackgroundView = [self.navigationBar valueForKey:@"_barBackgroundView"];
    if (barBackgroundView) {
        Ivar *viewivars = class_copyIvarList([barBackgroundView class], &viewOutCount);
        for (NSInteger i = 0; i < viewOutCount; ++i) {
            Ivar ivar = *(viewivars + i);
            NSLog(@"_barBackgroundView Propertys:\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
        }
        free(viewivars);
    }
    
    
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

```

### 扩展
**方法二中你可以写个`category`添加和移除**
