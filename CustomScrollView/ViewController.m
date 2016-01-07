//
//  ViewController.m
//  CustomScrollView
//
//  Created by lysongzi on 16/1/7.
//  Copyright © 2016年 lysongzi. All rights reserved.
//

#import "ViewController.h"
#import "YSModel.h"

//默认scrollView显示的模型数目
#define MODEL_NUMBER 5
//屏幕宽度
#define UISCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//默认图标缩放比率
#define SCALE_RATE 0.6

@interface ViewController ()<UIScrollViewDelegate>

//UI控件
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//模型数据
@property (strong, nonatomic) NSMutableArray *models;
//存储cell视图的数据
@property (strong, nonatomic) NSMutableArray *cellView;

//每个模型cell的宽度
@property (assign, nonatomic) NSInteger cellWidth;
//每个模型cell的高度
@property (assign, nonatomic) NSInteger cellHeight;

//记录当前居中cell的索引
@property (assign, nonatomic) NSInteger cellIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //计算ScrollView中每个cell的宽高
    self.cellWidth = self.scrollView.frame.size.width / MODEL_NUMBER;
    self.cellHeight = self.scrollView.frame.size.height;
    
    [self initModels];
    [self initScrollView];
}

- (void)initModels
{
    if (!self.models)
    {
        self.models = [NSMutableArray array];
    }
    
    [self.models addObject:[[YSModel alloc] initWithName:@"睡眠" logoName:@"sleep"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"浪漫" logoName:@"romantic"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"晚餐" logoName:@"dinner"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"会客" logoName:@"guest"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"观影" logoName:@"movie"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"阅读" logoName:@"read"]];
    [self.models addObject:[[YSModel alloc] initWithName:@"自定义" logoName:@"custom"]];
}

- (void)initScrollView
{
    //设定scrollView的contentSize，即scrollView中包含的cell个数计算出来的内容大小
    //+4是因为前后分别有两个空白的cell视图
    self.scrollView.contentSize = CGSizeMake(self.cellWidth * (self.models.count + 4), self.cellHeight);
    
    //清除scrollView的子视图
    //[self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //设置scrollView的委托对象
    self.scrollView.delegate = self;
    //隐藏水平和竖直方向的滚动条
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    //设置scrollView滚动的减速速率
    self.scrollView.decelerationRate = 0.95f;
    
    if (!self.cellView)
    {
        self.cellView = [NSMutableArray array];
    }
    else
    {
        [self.cellView removeAllObjects];
    }
    
    //添加两个空白的cell块
    for (int i = 0; i < 2; i++)
    {
        UIView *view = [self createEmptyCell:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        [self.scrollView addSubview:view];
    }
    
    //默认的六个块
    for (int i = 2; i < self.models.count + 2; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        
        //创建一个ImageView用于显示图标logo
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.cellWidth - 10, self.cellWidth - 10)];
        //设置图片为logo图片
        image.image = [UIImage imageNamed:[self.models[i - 2] logoName]];
        //开启可交互模式
        [image setUserInteractionEnabled:YES];
        
        image.tag = i - 2;
        view.tag = i -2;
        
        
        //最后一个"自定义"按钮添加特定触摸手势
        if (i == self.models.count + 1)
        {
            UITapGestureRecognizer *tapAddModel = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(tapToAddModel:)];
            [image addGestureRecognizer:tapAddModel];
        }
        //别的模型添加点击手势和向上滑动删除手势
        else
        {
            //添加点击手势
            UITapGestureRecognizer *tapEditModel = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tapToEditModel:)];
            [image addGestureRecognizer:tapEditModel];
            
            //添加滑动手势
            UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(swipeToDeleteModel:)];
            //设置滑动方向为向上
            [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
            [image addGestureRecognizer:swipeGesture];
        }
        
        [view addSubview:image];
        //记录下对应的cell视图
        [self.cellView addObject:view];
        [self.scrollView addSubview:view];
    }
    
    //添加两个空白的块
    for (long i = self.models.count + 2; i < self.models.count + 4; i++)
    {
        UIView *view = [self createEmptyCell:CGRectMake(self.cellWidth * i, 0, self.cellWidth, self.cellHeight)];
        [self.scrollView addSubview:view];
    }
    
    //设置默认居中为第三个模型
    [self.scrollView setContentOffset:CGPointMake(self.cellWidth * 2, 0) animated:YES];
    self.cellIndex = 2;
    //设置背景颜色和文字
    [self updateCellBackground:(int)self.cellIndex];
}

//创建空白cell视图
- (UIView *)createEmptyCell:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    //设置背景透明
    view.backgroundColor = [UIColor clearColor];
    //返回空白cell视图
    return view;
}

#pragma mark - 各种手势事件响应方法

- (void)tapToAddModel:(UIGestureRecognizer *)gr
{
    UIImageView *image = (UIImageView *)gr.self.view;
    
    //被点击的不是居中的元素，则进行滑动
    if (image.tag != self.cellIndex)
    {
        float destination = self.scrollView.contentOffset.x + (image.tag - self.cellIndex) * self.cellWidth;
        self.cellIndex = image.tag;
        
        [self.scrollView setUserInteractionEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(destination, 0) animated:YES];
    }
    //否则就是点击了居中的元素
    else
    {
        NSLog(@"Add Model.");
    }
}

//点击Logo图标是触发的事件
- (void)tapToEditModel:(UIGestureRecognizer *)gr
{
    UIImageView *image = (UIImageView *)gr.self.view;
    
    //被点击的不是居中的元素，则进行滑动
    if (image.tag != self.cellIndex)
    {
        float destination = self.scrollView.contentOffset.x + (image.tag - self.cellIndex) * self.cellWidth;
        self.cellIndex = image.tag;
        
        [self.scrollView setUserInteractionEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(destination, 0) animated:YES];
    }
    //否则就是点击了居中的元素
    else
    {
        //NSLog(@"进入编辑模式的界面");
    }
}

- (void)swipeToDeleteModel:(UIGestureRecognizer *)gr
{
    NSLog(@"Delete Model.");
}

#pragma mark - UIScrollViewDelegate 协议的实现

//scrollView 滑动过程减速完毕后回调的方法
//在这里进行计算，得出当前那个cell最靠近中间位置，并把该cell滑动到居中的位置
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cellJumpToIndex:scrollView];
}

//scrollView 拖拽操作结束(这个和上面方法不同之处在于，这里不会产生滑动的加速减速过程？)
//判断接下来是否会进行减速操作，如果不需要减速则在这里进行计算，得出当前那个cell最靠近中间位置，并把该cell滑动到居中的位置
//否则，不做任何处理。其实则就是要进行减速，减速完毕会回调scrollViewDidEndDecelerating。
//综上，都会计算需要居中哪个cell
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self cellJumpToIndex:scrollView];
    }
}

//滑动过程中回调的函数，无论是手动滑动的，还是代码动画滑动都会回调该方法
//在这里计算那个cell是可见的，然后计算缩放比例，进行动画缩放
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //处理每一个cell，计算它的缩放比例
    for (int i = 0; i < self.models.count; i++)
    {
        //cell左侧x位置
        float lead = self.cellWidth * (i + 2);
        //cell右侧x位置
        float tail = self.cellWidth * (i + 3);
        
        float rate = SCALE_RATE;
        
        //cell在屏幕左,右侧，不可见，设置为默认缩放比例0.6
        if (self.scrollView.contentOffset.x >= tail || (self.scrollView.contentOffset.x + UISCREEN_WIDTH) <= lead)
        {
            //暂时啥都不干
        }
        //cell在屏幕上
        else
        {
            float sub = lead - self.scrollView.contentOffset.x;
            //前半部分
            if (sub <= 2 * self.cellWidth)
            {
                rate = sub / (2 * self.cellWidth) * SCALE_RATE + SCALE_RATE;
            }
            else
            {
                rate = (UISCREEN_WIDTH - sub - self.cellWidth) / (2 * self.cellWidth) * SCALE_RATE + SCALE_RATE;
            }
        }
        //缩放该cell的视图
        [self viewToScale:rate target:self.cellView[i]];
    }
}

//按比例缩放视图
- (void)viewToScale:(float)scale target:(UIView *)view
{
    UIImageView *image = [[view subviews] lastObject];
    [UIView beginAnimations:@"scale" context:nil];
    image.transform = CGAffineTransformMakeScale(scale, scale);
    [UIView commitAnimations];
}

//滑动动画结束时调用的函数
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //根据居中的选项更新背景和文字
    [self updateCellBackground:(int)self.cellIndex];
    [self.scrollView setUserInteractionEnabled:YES];
}

//计算位置，居中选中的cell
- (void)cellJumpToIndex:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x < self.cellWidth * 0.5)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (self.scrollView.contentOffset.x > self.cellWidth * (self.models.count + 1.5))
    {
        [self.scrollView setContentOffset:CGPointMake(self.cellWidth * (self.models.count + 1), 0) animated:YES];
    }
    
    int index = (int)(self.scrollView.contentOffset.x / self.cellWidth + 0.5);
    [self.scrollView setContentOffset:CGPointMake(self.cellWidth * index, 0) animated:YES];
    
    //选定某个模式，进行模式更新等操作
    self.cellIndex = index;
}

//滑动到某个cell时更新视图的方法
- (void)updateCellBackground:(int)index
{
    self.name.text = [self.models[index] name];
}

//低内存通知的响应方法
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
