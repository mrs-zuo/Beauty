//
//  RSA.h
//  RSADemo
//
//  Created by macmini on 14-12-12.
//  Copyright (c) 2014年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

@interface RSA : NSObject
@property (nonatomic) SecKeyRef privateKey;
@property (nonatomic) SecKeyRef publicKey;

//+ (RSA *)sharedRSA;
-(id)init;
-(OSStatus)extractPublicFromCertificateFile:(NSString *)path;
-(NSString *)RSAEncryptByPublicKeyWithString:(NSString *)string;

//以下暂时没有用到
-(OSStatus)extractPrivateKeyFromPKCS12File:(NSString *)path  passPhrase:(NSString *)passphrase;
-(NSData *)RSAEncryptByPublicKeyWithData:(NSData *)data;
-(NSData *)RSAEncryptByPrivateKeyWithData:(NSData *)data;
-(NSData *)RSADecryptByPublicKeyWithData:(NSData *)data;
-(NSData *)RSADecryptByPrivateKeyWithData:(NSData *)data;

@end
