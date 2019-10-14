//
//  HZWPicker.m
#import "HZWPicker.h"

static const NSInteger HZWDefaultHeight = 248;

@interface HZWPicker()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray *hourArr;
    NSMutableArray *minArr;
    UIPickerView *picker;
    UIView *backgroundView;

   
}

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HZWPicker


- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect cg  = frame;
    cg.size.height = HZWDefaultHeight-44;
    frame = cg;
    self = [super initWithFrame:frame];
    if (self) {
        hourArr = [NSMutableArray array];
        minArr = [NSMutableArray array];
        [self inits];
    }
    return self;
}
- (void)inits
{
    for (int i = 0; i < 60; i++) {
        NSString *str = [NSString stringWithFormat:@"%02d", i];
        if (i<24) {
            [hourArr addObject:str];
        }
        [minArr addObject:str];
        
    }

    self.backgroundColor = UIColor.whiteColor;
    UIView *llView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    llView.backgroundColor = ssRGB(240, 240, 240);
    [llView addSubview:self.confirmButton];
    [llView addSubview:self.cancelButton];
    llView.userInteractionEnabled = YES;
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 24, SCREENWIDTH, 204)];
    picker.delegate = self;
    picker.dataSource = self;
    [picker selectRow:8 inComponent:0 animated:YES];
    [self addSubview:llView];
    [self addSubview:picker];
   
    [self addShadow];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];

}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH -100, 0, 100, 44)];
        _confirmButton.backgroundColor = UIColor.clearColor;
        
//        _confirmButton.backgroundColor = UIColor.redColor;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title = KHJLocalizedString(@"commit", nil);
        [_confirmButton setTitle:title forState:UIControlStateNormal];
        UIColor *color = UIColor.blueColor;
        [_confirmButton setTitleColor:color forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _cancelButton.backgroundColor = UIColor.clearColor;
//        _cancelButton.backgroundColor = UIColor.redColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title =KHJLocalizedString(@"cancel", nil);
        [_cancelButton setTitle:title forState:UIControlStateNormal];
        UIColor *color =  UIColor.blueColor;
        
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)confirm:(UIButton *)but
{

    NSString *hourString = [NSString stringWithFormat:@"%02ld:%02ld", [picker selectedRowInComponent:0],[picker selectedRowInComponent:2]];
    self.confirmBlock(hourString);
    [self tapBgview];
}
- (void)cancel:(UIButton *)but
{
    [self tapBgview];
}
#pragma mark - PickerDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            return [hourArr count];
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [minArr count];
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            return [hourArr objectAtIndex:row];
        }
            break;
        case 1:
        {
            return KHJLocalizedString(@"sHour", nil);
        }
            break;
        case 2:
        {
            return [minArr objectAtIndex:row];
        }
            break;
        case 3:
            return KHJLocalizedString(@"sMinute", nil);
            break;
        default:
            break;
    }
    return 0;
}


#pragma mark - PickerDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   
    
}

//添加遮罩
- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0, 1,SCREENWIDTH,SCREENHEIGHT);
    backgroundView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgview)];
    backgroundView.userInteractionEnabled = YES;
    [backgroundView addGestureRecognizer:gest];
    
}
- (void)tapBgview
{
    [backgroundView removeFromSuperview];
    [self removeFromSuperview];
}


@end
