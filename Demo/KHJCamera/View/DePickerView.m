//
//  DePickerView.m

#import "DePickerView.h"
#import "DeUIPickDate.h"
#import "Calculate.h"

@interface DePickerView()
{
    UIButton *leftBtn;
    UIButton *rightBtn;
    UIButton *showButton;
    dateChanged myBlock;
}
@end

@implementation DePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setDatePicker];
    }
    return self;
}
#pragma mark - setDataPicker
- (void)setDatePicker
{
    showButton = [self getShowButton];
    leftBtn = [self getLeftButton];
    [self addSubview:leftBtn];
    [self addSubview:showButton];
}

- (UIButton *)getShowButton
{
    if(!showButton){
        
        showButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-60, 0, 120, 40)];
        [showButton setImage:[UIImage imageNamed:@"videotape_icon_calendar_nor"] forState:UIControlStateNormal];
        

        [showButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        showButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [showButton addTarget:self action:@selector(clickCalendar) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *currentDateString = [Calculate getCurrentTimes];
    [showButton setTitle:currentDateString forState:UIControlStateNormal];
    return showButton;
}
- (UIButton *)getLeftButton
{
    if(!leftBtn){
        leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(showButton.frame.origin.x-50, 4, 32, 32)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"pre1"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(clickLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    return leftBtn;
}
- (UIButton *)getRightButton
{
    if(rightBtn == nil){
        
        rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(showButton.frame.origin.x+showButton.frame.size.width+18, 4, 32, 32)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(clickRight:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        rightBtn.hidden = YES;
    }
    return rightBtn;
}

- (void)clickCalendar
{
    [self setPiker];
}

// 点击左翻按钮
// Click the left button
- (void)clickLeft:(UIButton *)button
{
    NSString *setDatestring = [Calculate prevDay:showButton.currentTitle];
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    [self getRightButton];
    rightBtn.hidden = NO;
    [self handleDate:setDatestring];
}

// 点击右翻按钮
// Click the right button
- (void)clickRight:(UIButton*)button
{
    NSString *setDatestring = [Calculate nextDay:showButton.currentTitle];
    NSString *currentDate = [Calculate getCurrentTimes];
    if ([Calculate compareDate:setDatestring withDate:currentDate] == 0) {

        rightBtn.hidden = YES;

    }else{
        rightBtn.hidden = NO;
    }
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    
    [self handleDate:setDatestring];

}
- (void)changeRightBtnState:(BOOL)isH
{
    [self getRightButton];
    if (isH) {
        rightBtn.hidden = YES;

    }else{
        rightBtn.hidden = NO;

    }
}

// 日期选择
// date selection
- (void)setPiker
{
    DeUIPickDate *pickdate = [DeUIPickDate setDate];
    __weak typeof(showButton) weekShowButton = showButton;
    WeakSelf
    [pickdate passvalue:^(NSString *str) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weekShowButton setTitle:str forState:UIControlStateNormal];
            [weakSelf handleDate:str];
        });
    }];
}
- (void)handleDate:(NSString *)str
{
    myBlock(str);
}
- (void)dateChanged:(dateChanged)block
{
    myBlock = block;
}
@end



