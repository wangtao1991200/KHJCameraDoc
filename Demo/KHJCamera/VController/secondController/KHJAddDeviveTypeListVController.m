//
//  KAddDevVController.m
//
//  添加设备方法列表，"设备扫码添加" "设备热点连接" "有线连接"
//  Add device method list, "device scan code added" "device hotspot connection" "wired connection"
//
//

#import "KHJAddDeviveTypeListVController.h"
#import "addDevCell.h"
#import "KHJTipsViewController.h"
#import "LANVController.h"
#import "WCQRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface KHJAddDeviveTypeListVController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *gTable;
    NSArray *cateArray;
    NSArray *detailArray;
    NSArray *iconArr;
}
@end

@implementation KHJAddDeviveTypeListVController

- (instancetype)init
{
    self = [super init];
    if (self) {
        cateArray = [NSArray arrayWithObjects:
                     KHJLocalizedString(@"deviceScanAdd", nil),
                     KHJLocalizedString(@"DeviceApConnect", nil),
                     KHJLocalizedString(@"WlanConnect", nil),
                     nil];
        detailArray = [NSArray arrayWithObjects:
                       KHJLocalizedString(@"deviceScanDetail", nil),
                       KHJLocalizedString(@"DeviceApConnectDetail", nil),
                       KHJLocalizedString(@"WlanConnectDetail", nil),
                       nil];
        iconArr = [NSArray arrayWithObjects:@"scanning",@"rd",@"wx", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor   = bgVCcolor;
    self.title                  = KHJLocalizedString(@"addDevice", nil);
    [self setbackBtn];
    gTable                      = [self getGTable];
    [self.view addSubview:gTable];
    [self addNoti];
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveShare:) name:recieveShare_Noti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:recieveShare_Noti object:nil];
}

- (void)setbackBtn
{
    UIButton *btn       = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame           = CGRectMake(0, 0, 66, 44);
    
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [btn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBut = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)popViewController
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:recieveShare_Noti object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableView *)getGTable
{
    if (gTable == nil) {
        gTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64)];
        gTable.delegate = self;
        gTable.dataSource = self;
        gTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return gTable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"addCell";
    addDevCell *cell = (addDevCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell) {
        cell = [addDevCell xibTableViewCell];
    }
    cell.cateName.text = [cateArray objectAtIndex:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            // 二维码连接
            // QR code connection
            KHJTipsViewController *tipCtrl = [[KHJTipsViewController alloc] init];
            tipCtrl.vIndex = 0;
            [self.navigationController pushViewController:tipCtrl animated:YES];
        }
            break;
        case 1:
        {
            // 热点连接
            // hotspot connection
            KHJTipsViewController *tipCtrl = [[KHJTipsViewController alloc] init];
            tipCtrl.vIndex = 1;
            [self.navigationController pushViewController:tipCtrl animated:YES];
        }
            break;
        case 2:
        {
            // 有线链接
            // Wired link
            LANVController *lnVC = [[LANVController alloc] init];
            [self.navigationController pushViewController:lnVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)QRCodeScanVC:(UIViewController *)scanVC
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                        NSLog(@"The user first agreed to the permission to access the camera--%@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        NSLog(@"User denied access to camera for the first time--%@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                [self.navigationController pushViewController:scanVC animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:KHJLocalizedString(@"cameraPrivacy", nil ) preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                NSLog(@"Unable to access the album due to system reasons");
                break;
            }
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil)
                                                                    message:KHJLocalizedString(@"noCamera", nil)
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil)
                                                     style:(UIAlertActionStyleDefault)
                                                   handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - recieveShare

- (void)recieveShare:(NSNotification *)noti
{
    
}



@end
