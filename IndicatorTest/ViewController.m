//
//  ViewController.m
//  IndicatorTest
//
//  Created by gameloft on 16/6/18.
//  Copyright © 2016年 gameloft. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "CommendViewController.h"
#import "ListViewController.h"
#import "RadioViewController.h"
#import "LeaderBoardViewController.h"

#define NAVIGATEHEIGHT self.navigationController.navigationBar.bounds.size.height + \
[UIApplication sharedApplication].statusBarFrame.size.height

@interface ViewController ()<UIScrollViewDelegate>

//** indicator */
@property (nonatomic, weak) UIView *indicatorView;

//** red line */
@property (nonatomic, weak) UIView *indicatorLine;

//** button */
@property (nonatomic, weak) UIButton *indicatorDisableBtn;

//** scrollView */
@property (nonatomic, weak) UIScrollView *contentScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //创建指示器
    [self setupIndicator];
    [self addChildViews];
    //创建Scrollview
    [self initScrollView];
    
    
}

- (void)addChildViews
{
    CommendViewController *cmmVC = [[CommendViewController alloc] init];
    cmmVC.title = @"个性推荐";
    [self addChildViewController:cmmVC];
    
    ListViewController *listVC = [[ListViewController alloc] init];
    listVC.title = @"歌单";
    [self addChildViewController:listVC];
    
    RadioViewController *radioVC = [[RadioViewController alloc] init];
    radioVC.title = @"主播频道";
    [self addChildViewController:radioVC];
    
    LeaderBoardViewController *leaderVC = [[LeaderBoardViewController alloc] init];
    leaderVC.title = @"排行榜";
    [self addChildViewController:leaderVC];
}

/**
 *  创建Scrollview咯~
 *
 *  @return void
 */
- (void)initScrollView
{
    //禁止系统自动调整ScrollView的布局，以免影响我们自己的布局
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建scrollview
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = [UIScreen mainScreen].bounds;
    
    //使用scrollview的分页功能，如果拖动没到页面的一半，不会切换到下一页
    scrollView.pagingEnabled = YES;
    //设置scrollview的内容显示大小，一共有4个屏幕宽度
    scrollView.contentSize = CGSizeMake(self.view.width * 4, 0);
    
    scrollView.backgroundColor = [UIColor lightGrayColor];
    //设置scrollview的代理
    scrollView.delegate = self;
    
    //把scrollview添加到view的最底层
    [self.view insertSubview:scrollView atIndex:0];
    
    //保存scrollview到属性，方便后面调用
    self.contentScrollView = scrollView;
    
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];

}

//滑动scrollview时更改content
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    UIButton *btn = self.indicatorView.subviews[index];
    //手动调用button的响应函数以便在拖拽scrollview时button跟着变化，以实现不同操作的相同结果
    [self btnClicked:btn];
    
    //当点击到的button对应的view没有添加到scrollview中时，手动调用下scrollViewDidEndScrollingAnimation函数来滚动scrollview并创建子视图。
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //根据contentOffset的x值与scrollview的宽度的比值来确定当前滑动到了哪个view的内容范围
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    //上一步算出来的index就是我们需要显示的view的索引，从childViewControllers中取出对应的ViewController
    UIViewController *vc = self.childViewControllers[index];
    
    //设置取出来的vc的x和高度，填满scrollview
    vc.view.x = scrollView.contentOffset.x;
    vc.view.height = scrollView.height;
    
    //最后添加vc到scrollview中
    [scrollView addSubview:vc.view];
}

/**
 *  我们来创建指示器！
 */
- (void)setupIndicator
{
    UIView *indicatorView = [[UIView alloc] init];
    indicatorView.frame = CGRectMake(0, NAVIGATEHEIGHT, self.view.bounds.size.width, 35);
    //设置一个背景色，先设置半透明红色，方便我们观察
    indicatorView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    //保存到属性中，后面会用到
    self.indicatorView = indicatorView;
    
    
    //这里用到的height、x、y、width都是我给UIView写的分类中的方法。
    //因为不能直接给这些属性赋值，必须创建一个frame，然后替换控件原有的frame才能达到更改x，y，宽高等属性的目的
    //所以我写了个UIView分类来实现了这些属性的getter和setter方法，方便使用
    UIView *indicatorLine = [[UIView alloc] init];
    indicatorLine.height = 2;
    indicatorLine.y = indicatorView.height - indicatorLine.height;
    indicatorLine.width = 40;
    indicatorLine.x = 0;
    //先给个绿色，方便观察
    indicatorLine.backgroundColor = [UIColor redColor];
    //保存到属性中
    self.indicatorLine = indicatorLine;
  
    //添加4个button
    NSArray *titles = @[@"个性推荐", @"歌单", @"主播电台", @"排行榜"];
    CGFloat buttonHeight = indicatorView.height;
    CGFloat buttonWidth = indicatorView.width / 4;
    CGFloat buttonY = 0;
    NSUInteger count = 4;
    
    for (int i = 0; i < count; ++i) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.tag = i;
        //正常状态下title为黑色
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        ////这里注意要使用Disable状态，防止button被选中后(selected)一直是红色，导致所有button变红
        //后面会设置button的disable状态来调整button中文字的颜色
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        btn.frame = CGRectMake(buttonWidth * i, buttonY, buttonWidth, buttonHeight);
        //修改title字体
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        //button 添加响应事件
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.indicatorView addSubview:btn];
        
        if (i == 0) {
            //默认选中第一个button，并disable它
            btn.enabled = NO;
            //保存disable的button到属性中，方便后面更改被disable的button的状态
            self.indicatorDisableBtn = btn;
            
            //这个必须调用，不然指示器的frame不正确。
            [btn layoutIfNeeded];
            
            //重新设置红线宽度和位置,让它移动到第一个button的位置
            self.indicatorLine.width = btn.titleLabel.width;
            self.indicatorLine.centerX = btn.centerX;
        }
        
    }
    
    //注意，这里是self.indicatorView，不是self.view，因为我们要把红线添加到indicatorView里
    [self.indicatorView addSubview:indicatorLine];
    [self.view addSubview:indicatorView];
}

- (void)btnClicked:(UIButton *)btn
{
    //设置上次点击被disable的button为enable状态
    self.indicatorDisableBtn.enabled = YES;
    //当前点击的button为disable状态，好显示红色title
    btn.enabled = NO;
    //保存当前点击的button
    self.indicatorDisableBtn = btn;
    
    //设置红线的动画
    [UIView animateWithDuration:0.2f animations:^{
        self.indicatorLine.width = btn.titleLabel.width;
        self.indicatorLine.centerX = btn.centerX;
    }];
    
    //添加滑动scrollview，点击button后scrollview跟着滑动到相应位置
    //通过选中的button的tag值来判断现在选择的是第几个button，然后根据tag值决定需要滚动几个view的宽度
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = btn.tag * self.contentScrollView.width;
    //这里设置了animated参数为YES，在自动滚动scrollview的动画完成时会调用scrollViewDidEndScrollingAnimation
    [self.contentScrollView setContentOffset:offset animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
