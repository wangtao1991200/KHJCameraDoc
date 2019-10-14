//
//  CreateTwoCode.h
#import <Foundation/Foundation.h>

@interface CreateTwoCode : NSObject

+ (UIImage *)createTCode:(NSString *)pString;
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;


@end
