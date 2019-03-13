//
//  HDRSA.h
//  TestConfuse
//
//  Created by HanDong Wang on 2019/3/7.
//  Copyright © 2019 Chiery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface HDRSA : NSObject {
    
    SecKeyRef publicKey;
    
    SecCertificateRef certificate;
    
    SecPolicyRef policy;
    
    SecTrustRef trust;
    
    size_t maxPlainLen;
    
}

- (NSData *)encryptWithData:(NSData *)content;
- (NSData *)decryptWithData:(NSData *)content;
- (NSData *)encryptWithString:(NSString *)content;
- (NSData *)decryptWithString:(NSString *)content;

@end
