
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DataHandel : NSObject

+(void)GetDataWithURLstr:(NSString *)urlstr complete:(void (^)(id result))block;

@end
