//
//  HDRSA.m
//  TestConfuse
//
//  Created by HanDong Wang on 2019/3/7.
//  Copyright © 2019 Chiery. All rights reserved.
//

#import "HDRSA.h"
#import "NSData+Base64.h"

@implementation HDRSA

- (id)init {
    self = [super init];
    
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"public_key"
                                                              ofType:@"der"];
    if (publicKeyPath == nil) {
        NSLog(@"Can not find pub.der");
        return nil;
    }
    
    NSData *publicKeyFileContent = [NSData dataWithContentsOfFile:publicKeyPath];
    if (publicKeyFileContent == nil) {
        NSLog(@"Can not read from pub.der");
        return nil;
    }
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, ( __bridge CFDataRef)publicKeyFileContent);
    if (certificate == nil) {
        NSLog(@"Can not read certificate from pub.der");
        return nil;
    }
    
    policy = SecPolicyCreateBasicX509();
    OSStatus returnCode = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (returnCode != 0) {
        NSLog(@"SecTrustCreateWithCertificates fail. Error Code: %d", returnCode);
        return nil;
    }
    
    SecTrustResultType trustResultType;
    returnCode = SecTrustEvaluate(trust, &trustResultType);
    if (returnCode != 0) {
        NSLog(@"SecTrustEvaluate fail. Error Code: %d", returnCode);
        return nil;
    }
    
    publicKey = SecTrustCopyPublicKey(trust);
    if (publicKey == nil) {
        NSLog(@"SecTrustCopyPublicKey fail");
        return nil;
    }
    
    maxPlainLen = SecKeyGetBlockSize(publicKey) - 12;
    return self;
}

- (NSData *)encryptWithData:(NSData *)content {
    
    size_t plainLen = [content length];
    if (plainLen > maxPlainLen) {
        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain
               length:plainLen];
    
    size_t cipherLen = 256;
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", returnCode);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

- (NSData *)decryptWithData:(NSData *)cipherData {
    if (!publicKey) {
        return nil;
    }
    if (!cipherData) {
        return nil;
    }
    
    size_t keySize = SecKeyGetBlockSize(publicKey) * sizeof(uint8_t);
    double totalLength = [cipherData length];
    size_t blockSize = keySize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *plainData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *plainBuffer = malloc(keySize);
        memset(plainBuffer, 0, keySize);
        OSStatus status = noErr;
        size_t plainBufferSize = keySize;
        status = SecKeyDecrypt(publicKey,
                               kSecPaddingNone, // 解密的时候一定要用 无填充模式，拿到所有的数据自行解析
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               plainBuffer,
                               &plainBufferSize
                               );
        
        NSAssert(status == noErr, @"Decrypt error");
        if(status != noErr){
            free(plainBuffer);
            return nil;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:plainBuffer length:plainBufferSize];
        
        NSData *startData = [data subdataWithRange:NSMakeRange(0, 1)];
        // 开头应该是 0001 但是原生解出来之后把开头的 00 忽略了
        if ([[startData description] isEqualToString:@"<01>"]) {
            Byte flag[] = {0x00};
            NSRange startRange = [data rangeOfData:[NSData dataWithBytes:flag length:1] options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
            NSUInteger s = startRange.location + startRange.length;
            if (startRange.location != NSNotFound && s < data.length) {
                data = [data subdataWithRange:NSMakeRange(s, data.length - s)];
            }
        }
        
        [plainData appendData:data];
        free(plainBuffer);
    }
    
    return plainData;
}

- (NSData *)encryptWithString:(NSString *)content {
    return [self encryptWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)decryptWithString:(NSString *)content {
    return [self decryptWithData:[NSData base64DataFromString:content]];
}

- (void)dealloc{
    CFRelease(certificate);
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(publicKey);
}

@end
