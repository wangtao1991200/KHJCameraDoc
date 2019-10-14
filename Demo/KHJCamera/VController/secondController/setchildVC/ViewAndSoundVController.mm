//
//  ViewAndSoundVController.m
//
//
//
//
//

#import "ViewAndSoundVController.h"
#import "KHJAllBaseManager.h"
#import "CustomSlider.h"

@interface ViewAndSoundVController ()
{
    UISwitch   *switchView;
    CustomSlider *cslider;
    UISlider *voiceSlider;
    UILabel *vLabel;//音量显示
}
@end

@implementation ViewAndSoundVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
    }
    self.title = KHJLocalizedString(@"deviceVolume", nil);
    self.view.backgroundColor = bgVCcolor;

    [self setbackBtn];
    [self setMainView];
    [self getDeviceVoice];
}
- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMainView
{

    UIView *v3 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, SCREENWIDTH, 80)];
    v3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v3];

    UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    lab3.text = KHJLocalizedString(@"volume", nil);
    [v3 addSubview:lab3];
    voiceSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, lab3.frame.size.height+lab3.frame.origin.y+20, SCREENWIDTH-40, 20)];
    voiceSlider.maximumValue = 100;
    voiceSlider.minimumValue = 0;
    voiceSlider.minimumTrackTintColor = ssRGB(82, 158, 154);
    [voiceSlider setThumbImage:[UIImage imageNamed:@"round1"] forState:UIControlStateNormal];
    [voiceSlider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventValueChanged];
    [voiceSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];

    [v3 addSubview:voiceSlider];
    vLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-100, 20, 80, 20)];
    vLabel.text = @"0%";
    vLabel.textAlignment = NSTextAlignmentRight;
    vLabel.textColor = ssRGB(82, 158, 154);
    [v3 addSubview:vLabel];
}
-(void)touchUp:(UISlider *)slider
{
    CLog(@"touchUp == %d",(int)slider.value);
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager setDeviceVolume:(int)slider.value returnBlock:^(BOOL success) {
            [weakSelf setDeviceVolumeCallback:success];
        }];
    }
    [[KHJToast share] showToastActionWithToastType:_WarningType
                                      toastPostion:_CenterPostion
                                               tip:@""
                                           content:KHJLocalizedString(@"setVolume", nil)];
}

- (void)setDeviceVolumeCallback:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}
-(void)touchSlider:(UISlider *)slider
{
    vLabel.text = [NSString stringWithFormat:@"%d%%",(int)slider.value];
}
- (void)getDeviceVoice
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getDeviceVolume:^(int volume) {
            [weakSelf getDeviceVolumeCallback:volume];
        }];
    }
}
- (void)getDeviceVolumeCallback:(int)success
{
    CLog(@"音量 == %d",success);
    __weak typeof(voiceSlider) weakVoiceSlider= voiceSlider;
    __weak typeof(vLabel) weakVLabel= vLabel;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakVoiceSlider.value = success;
        weakVLabel.text = [NSString stringWithFormat:@"%d%%",success];
    });
}

- (void)connectofflineDevice:(NSString *)uid
{
    if([uid isEqualToString:self.uuidStr]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"connectTerminate", nil)];
        });
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


























