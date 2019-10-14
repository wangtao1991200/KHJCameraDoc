//
//  DeErrorCodeManager.m

#import "DeErrorCodeManager.h"

@implementation DeErrorCodeManager

+ (NSString *)errorCode:(int)code
{
    NSString *error = @"";
    switch ((NSInteger)code) {
        case 0:
            error = DeLocalizedString(@"ServerError", nil);
            break;
        case 10100:
            error = DeLocalizedString(@"paramsError", nil);
            break;
        case 10101:
            error = DeLocalizedString(@"addFailureByPwdError", nil);
            break;
        case 10102:
            error = DeLocalizedString(@"emailHasBind", nil);
            break;
        case 10103:
            error = DeLocalizedString(@"pwdError", nil);
            break;
        case 10104:
            error = DeLocalizedString(@"VerificationCodeExpires", nil);
            break;
        case 10105:
            error = DeLocalizedString(@"permissionDenied", nil);
            break;
        case 10106:
            error = DeLocalizedString(@"notRepeatShare", nil);
            break;
        case 10107:
            error = DeLocalizedString(@"cellPhoneHasBind", nil);
            break;
        case 10108:
            error = DeLocalizedString(@"verificationCodeError", nil);
            break;
        case 10109:
            error = DeLocalizedString(@"userUnregistered", nil);
            break;
        case 10110:
            error = DeLocalizedString(@"loginExpired", nil);
            break;
        case 10111:
            error = DeLocalizedString(@"On-line", nil);
            break;
        case 10112:
            error = DeLocalizedString(@"DevShareMax", nil);
            break;
        case 10114:
            error = DeLocalizedString(@"NoCloudServices", nil);
            break;
        case 10115:
            error = DeLocalizedString(@"HadCloudServices", nil);
            break;
        case 10116:
            error = DeLocalizedString(@"CannotUntie", nil);
            break;
        case 10117:
            CLog(@"该账号在异地登录");
            break;
        case 10118:
            error = DeLocalizedString(@"vCodeError", nil);
            break;
        case 10119:
            error = DeLocalizedString(@"DeviceUnbound", nil);
            break;
        case 10120:
            error = DeLocalizedString(@"HadReceive", nil);
            break;
        case 10121:
            error = DeLocalizedString(@"NoActivity", nil);
            break;
        case 10122:
            error = DeLocalizedString(@"UidIllegality", nil);
            break;
        case 10123:
            error = DeLocalizedString(@"NoSuchPackage", nil);
            break;
        default:
            break;
    }
    return error;
}

@end
