//
//  HDCrypto.m
//  TestConfuse
//
//  Created by HanDong Wang on 2019/3/13.
//  Copyright © 2019 Chiery. All rights reserved.
//

#import "HDCrypto.h"
#import "RSAUtil.h"
#import "AES.h"
#import <CommonCrypto/CommonRandom.h>

NSString *publicRSAKey = @"-----BEGIN PUBLIC KEY-----\
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAom1B5DlE84eU/H+zXNf1\
79aFs0nYa2+7Pj8dvU41VGCLa4+MJjP8XugBIEY4hi7KuRNYbNT4428mo1WqldJL\
rAyBqlZLOISja3Bf7ETjDWOndF4FHsBRGA8Rw8E9b62onamNGA/4fk997agl6ywz\
6xhCknEeV7ZieZR78SRLmOBrbC24SHglVhesbclCPEyDbt1Etue+sR0Lnmn7eAeH\
8UzStFCOVhgZM1NcZp6KGb8lfvl58Tj4nCDQsMHlmRkLrUEFm2EcOPu3c67nLQ4b\
MMBeWK8hUXadm3vGrtj9b4942Pps3BCD1w4ARPnjQ9t2j4U9oDFHc6FSgs6Yo8Iu\
PQIDAQAB\
-----END PUBLIC KEY-----";

@implementation HDCrypto

+ (NSDictionary *)encrypt:(NSDictionary *)dict {
    // 得到随机数
    NSString *randomString = [self randomString:16];
    
    // 参数加密
    NSString *rsaEncryptString = [RSAUtil encryptString:randomString publicKey:publicRSAKey];
    NSString *jsonEncryptString = nil;
    
    // 参数统一加密
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    if (paramData) {
        NSString *jsonString = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
        if (jsonString) {
            jsonEncryptString = [AES encrypt:jsonString password:randomString];
        }
    }
    
    // 整理需要返回的数据
    if (rsaEncryptString && jsonEncryptString) {
        return @{
                 @"dafefsadfefeasd": rsaEncryptString,
                 @"jijaijiheawfndu": jsonEncryptString
                 };
    }
    return nil;
}

+ (NSDictionary *)decrypt:(NSDictionary *)dict {
    // 取出对应的加密数据
    NSString *secretKey = dict[@"dafefsadfefeasd"];
    NSString *contentData = dict[@"jijaijiheawfndu"];
    
    if (secretKey && contentData) {
        NSString *decryptAESKey = [RSAUtil decryptString:secretKey publicKey:publicRSAKey];
        if (decryptAESKey) {
            NSString *decryptContentString = [AES decrypt:contentData password:decryptAESKey];
            // 剥离加密是填充的\0控制符
            NSString *stripString = [decryptContentString stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
            if (stripString) {
                NSDictionary *responseCotentDict = [NSJSONSerialization JSONObjectWithData:[stripString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if (responseCotentDict) {
                    return responseCotentDict;
                }
            }
        }
    }
    return nil;
}

+ (NSString *)randomString:(NSInteger)length {
    length = length/2;
    unsigned char digest[length];
    CCRNGStatus status = CCRandomGenerateBytes(digest, length);
    NSString *s = nil;
    if (status == kCCSuccess) {
        s = [self stringFrom:digest length:length];
    }
    return s;
}

+ (NSString *)stringFrom:(unsigned char *)digest length:(NSInteger)leng {
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < leng; i++) {
        [string appendFormat:@"%02x",digest[i]];
    }
    return string;
}

@end
