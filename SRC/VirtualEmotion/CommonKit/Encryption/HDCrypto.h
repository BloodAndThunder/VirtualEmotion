//
//  HDCrypto.h
//  TestConfuse
//
//  Created by HanDong Wang on 2019/3/13.
//  Copyright © 2019 Chiery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDCrypto : NSObject

+ (NSDictionary *)encrypt:(NSDictionary *)dict;
+ (NSDictionary *)decrypt:(NSDictionary *)dict;

@end
