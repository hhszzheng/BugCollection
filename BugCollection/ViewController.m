//
//  ViewController.m
//  BugCollection
//
//  Created by zyf on 2017/6/1.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "SCLAlertView.h"
#import "UIImage+SubImage.h"
@interface ViewController ()
@property (nonatomic, strong) UIImage *sendImage;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, assign) int selectNum;

@end

@implementation ViewController
- (NSMutableArray *)labelArray{
    if (!_labelArray) {
        _labelArray = [NSMutableArray array];
    }
    return _labelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *leftBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:@"截屏" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1)];
    UIBarButtonItem *leftBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"清屏" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2)];

    self.navigationItem.leftBarButtonItems = @[leftBarButtonItem1,leftBarButtonItem2];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.title = @"截屏测试";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.selectNum = 0;
    
    
}

//跳转
- (void)buttonAction{
    SecondViewController *seVC = [[SecondViewController alloc] init];
    seVC.sendImage = self.sendImage;
    [self.navigationController pushViewController:seVC animated:YES];
    
}
//截屏
- (void)buttonAction1{
    
    self.sendImage = [self screenView:self.view];
    
    
}
//清屏
- (void)buttonAction2{
    self.selectNum = 0;
    
    for (UIButton *label in self.labelArray) {
        [label removeFromSuperview];
    }
    [self.labelArray removeAllObjects];
}



//截屏
- (UIImage*)screenView:(UIView *)view{
    CGRect rect = view.frame;
//    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
    
}




//触摸屏幕添加 标签点
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    int x = point.x;
    int y = point.y;
    NSLog(@"touch (x, y) is (%d, %d)", x, y);
    
    
    @weakify(self);
    //监听数组元素 大于三个不能创建
    [RACObserve(self, self.labelArray) subscribeNext:^(NSMutableArray *array) {
       @strongify(self);
        if (array.count <3) {
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setHorizontalButtons:YES];
            
            SCLTextView *textField = [alert addTextField:@"标签内容"];
            alert.hideAnimationType = SCLAlertViewHideAnimationSimplyDisappear;
            [alert addButton:@"确定" actionBlock:^(void) {
                NSLog(@"Text value: %@", textField.text);
                
                
                CGSize titleSize = [textField.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:textField.font.fontName size:textField.font.pointSize]}];
                
                
                self.selectNum ++;
                UIButton *seleButton = [UIButton buttonWithType:UIButtonTypeCustom];
                seleButton.backgroundColor = [UIColor blackColor];
                seleButton.frame = CGRectMake(x, y, titleSize.width+30, 30);
                [seleButton setTitle:[NSString stringWithFormat:@"%@",textField.text] forState:UIControlStateNormal];
                //    [seleButton setTitle:@"移动" forState:UIControlEventTouchDown];
                [seleButton addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
                [seleButton addTarget:self action:@selector(dragEnded:withEvent: )forControlEvents: UIControlEventTouchUpInside |
                 UIControlEventTouchUpOutside];
                seleButton.tag = self.selectNum;
                [self.view addSubview:seleButton];
                [self.labelArray addObject:seleButton];
                //button长按事件
                UILongPressGestureRecognizer*longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnLong:)];
                longPress.minimumPressDuration= 1;//定义按的时间
                [seleButton addGestureRecognizer:longPress];

                
            }];
            
            [alert showEdit:self title:@"问题描述" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
    
        }else{
            [self showHint:@"最多添加三个标签"];
        }
        
    }];
    
    

    
    
}

//拖拽移动 标签点
- (void) dragMoving: (UIControl *) c withEvent:ev{
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void) dragEnded: (UIControl *) c withEvent:ev{
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

//长按标签点 编辑 删除 等等
-(void)btnLong:(UILongPressGestureRecognizer*)gestureRecognizer{
    if([gestureRecognizer state]== UIGestureRecognizerStateBegan){
        UIButton *button = (UIButton *)gestureRecognizer.self.view;
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"编辑" actionBlock:^{
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert setHorizontalButtons:YES];
            SCLTextView *textField = [alert addTextField:@"标签内容"];
            textField.text = button.titleLabel.text;
            alert.hideAnimationType = SCLAlertViewHideAnimationSimplyDisappear;
            [alert addButton:@"确定" actionBlock:^(void) {
                NSLog(@"Text value: %@", textField.text);
                CGSize titleSize = [textField.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:textField.font.fontName size:textField.font.pointSize]}];
                button.width = titleSize.width+30;
                [button setTitle:textField.text forState:UIControlStateNormal];
            }];
            [alert showEdit:self title:@"问题描述" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
            
        }];
        [alert addButton:@"删除" actionBlock:^(void) {
            NSLog(@"删除 button tapped");
            
            [self.labelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                UILabel *view = obj;
                if (view.tag == gestureRecognizer.self.view.tag) {
                    [self.labelArray removeObject:view];
                    [view removeFromSuperview];
                }else{
                    
                }
                
            }];
            
            
        }];
        
        [alert showSuccess:@"标签信息" subTitle:[NSString  stringWithFormat:@"%@",button.titleLabel.text] closeButtonTitle:@"取消" duration:0.0f];
        
    }
}


@end
