//
//  RSA.m
//  RSADemo
//
//  Created by macmini on 14-12-12.
//  Copyright (c) 2014年 macmini. All rights reserved.
//

#import "RSA.h"

@implementation RSA

- (id)init {
    
    self = [super init];
    if (self) {
        self.privateKey = NULL;
        self.publicKey = NULL;
    }
    
    return self;
}

-(OSStatus)extractPrivateKeyFromPKCS12File:(NSString *)path  passPhrase:(NSString *)passphrase
{
    OSStatus status = -1;
    SecIdentityRef identity;
    
    if(!_privateKey)
    {
        SecTrustRef trust;
        SecTrustResultType resultType;
        NSData *data = [NSData dataWithContentsOfFile:path];
        if(data)
        {
            CFStringRef password = (__bridge CFStringRef)(passphrase);
            const void * key[] = {kSecImportExportPassphrase};
            const void * value[] = {password};
            
            //create a dictionary with password and use it when open the file
            CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, key, value, 1, NULL, NULL);
            //create a array to store the result after opened the file
            CFArrayRef items =CFArrayCreate(kCFAllocatorDefault, NULL, 0, NULL);
            //using options and items as a param get the result
            status = SecPKCS12Import((__bridge CFDataRef)(data), options, &items);
            if(status == errSecSuccess)
            {
                //get the dictionary contain the identity, trust and cert
                CFDictionaryRef identity_trust_dic = CFArrayGetValueAtIndex(items, 0);
                //get the identity from the dictionary
                identity = (SecIdentityRef)CFDictionaryGetValue(identity_trust_dic, kSecImportItemIdentity);
                //get the trust from the dictionary
                trust = (SecTrustRef)CFDictionaryGetValue(identity_trust_dic, kSecImportItemTrust);
                CFArrayRef certs  = CFDictionaryGetValue(identity_trust_dic, kSecImportItemCertChain);
                if ([(__bridge NSArray*)certs count] && trust && identity)
                {
                    //trust all certificates , or evaluate certificates is failure
                    status = SecTrustSetAnchorCertificates(trust, certs);
                    if (status == errSecSuccess)
                    {
                        status = SecTrustEvaluate(trust, &resultType);
                        if (resultType == kSecTrustResultUnspecified || resultType == kSecTrustResultProceed ||resultType == errSecSuccess)
                        {
                            status = SecIdentityCopyPrivateKey(identity, &_privateKey);
                            if (status == errSecSuccess && _privateKey)
                                NSLog(@"Get private key successfully!");
                        }
                    }
                }
            }
            if(options)
                CFRelease(options);
        }
    }
    return status;
}
-(OSStatus)extractPublicFromCertificateFile:(NSString *)path
{
    OSStatus status = -1;
    
    if(_publicKey == NULL)
    {
        //CFType used for performing X.509 certificate trust evaluations.
        SecTrustRef trust = NULL;
        //Specifies the trust result type.
        SecTrustResultType trustResult = -1;
        
        NSData *dataFromCert = [NSData dataWithContentsOfFile:path];
        
        if (dataFromCert)
        {
            //create certificate
            SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)(dataFromCert));
            //create a trust policy object of  Basic X509  (Basic X509 and SSL are two policy in IOS)
            SecPolicyRef policy = SecPolicyCreateBasicX509();
            //create a trust object from the certificate 
            status = SecTrustCreateWithCertificates(cert, policy, &trust);
            
            if (status == errSecSuccess)
            {
                NSArray *arrayCerts = [NSArray arrayWithObject:(__bridge id)(cert)];
                //Sets the anchor certificates for a given trust.
                status = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)(arrayCerts));
                if(status == errSecSuccess)
                {
                    status = SecTrustEvaluate(trust , &trustResult);
                    if(status == errSecSuccess && (trustResult == kSecTrustResultUnspecified || trustResult == kSecTrustResultProceed))
                    {
                        _publicKey = SecTrustCopyPublicKey(trust);

                        if(_publicKey) NSLog(@"Got public key successfully!");
                        if (cert) CFRelease(cert);
                        if (policy) CFRelease(policy);
                        if (trust) CFRelease(trust);
                    }
                }
            }
        }
    }
    
    return status;
}

- (NSData *)RSAEncryptWithData:(NSData *)plainData usingPublicKey:(BOOL)yes
{
    SecKeyRef key = yes ? _publicKey : _privateKey;
    //
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    //cipher size after encrypted
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    
    size_t totalLength = [plainData length];
    //the every block size of plain data (divide into some pices when data is large enough)
    size_t blockSize = cipherBufferSize - 12;
    //count of block
    size_t blockCount = ceil((double)totalLength/blockSize);
    NSMutableData *encryptedData = [NSMutableData data];
    
    for(int i  = 0; i < blockCount ; ++i )
    {
        NSInteger location = i * blockSize;
        //the last block size may less than presupposed
        NSInteger dataSegmentRealSize = MIN(blockSize, [plainData length] - location);
        NSData *dataSegment  = [plainData subdataWithRange:NSMakeRange(location, dataSegmentRealSize)];
        //using public (only) key encrypt the data, data segment is the original data
        OSStatus status = SecKeyEncrypt(key,
                                        kSecPaddingPKCS1,
                                        [dataSegment bytes],
                                        dataSegmentRealSize,
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == errSecSuccess)
        {
            NSData *encryptedDataSegment  = [[NSData alloc] initWithBytes:cipherBuffer length:cipherBufferSize];
            
            [encryptedData appendData:encryptedDataSegment];
            
        }
        else
        {
            if (cipherBuffer)
                free(cipherBuffer);// map key words "malloc"
            return nil;
        }
    }
    if(cipherBuffer)
        free(cipherBuffer); // map key words "malloc"
    return encryptedData;
    
}

-(NSData *)RSADEcryptWithData:(NSData *)cipherData usingPrivateKey:(BOOL)yes
{
    SecKeyRef key = yes ? _privateKey : _publicKey;
    //block size of key
    size_t plainBufferSize = SecKeyGetBlockSize(key);
    //plain buffer, fill with the decrypted data
    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
    
    NSInteger totalLength = [cipherData length];
    size_t blockSize = plainBufferSize;
    //the every block size of plain data (divide into some pices when data is large enough, the as encrypt)
    size_t blockCount = ceil((double)totalLength / blockSize);
    
    NSMutableData *decryptedData = [NSMutableData data];
    
    for (int i = 0; i < blockCount; i++) {
        NSInteger loction = i * blockSize;
        //the last block size may less than presupposed
        NSInteger dataSegmentSize = MIN(blockSize , totalLength - loction);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loction, dataSegmentSize)];
        //using private (only) key decrypt the data, data segment is the original data
        OSStatus status  = SecKeyDecrypt(key,
                                         kSecPaddingPKCS1,
                                         [dataSegment bytes],
                                         dataSegmentSize,
                                         plainBuffer,
                                         &plainBufferSize);
        if (status == errSecSuccess)
        {
            NSData *decryptedDataSegment = [[NSData alloc] initWithBytes:plainBuffer length:plainBufferSize];
            [decryptedData appendData:decryptedDataSegment];
        }
        else
        {
            if (plainBuffer)
                free(plainBuffer); // map key words "malloc"
            return nil;
        }
    }
    if (plainBuffer)
        free(plainBuffer); // map key words "malloc"
    return decryptedData;
}


-(NSData *)RSAEncryptByPublicKeyWithData:(NSData *)data
{
   return [self RSAEncryptWithData:data usingPublicKey:YES];
}

-(NSData *)RSAEncryptByPrivateKeyWithData:(NSData *)data
{
   return [self RSAEncryptWithData:data usingPublicKey:NO];
}

-(NSData *)RSADecryptByPublicKeyWithData:(NSData *)data
{
    return [self RSADEcryptWithData:data usingPrivateKey:NO];
}

-(NSData *)RSADecryptByPrivateKeyWithData:(NSData *)data
{
    return [self RSADEcryptWithData:data usingPrivateKey:YES];
}

-(NSString *)RSAEncryptByPublicKeyWithString:(NSString *)orignal
{
    NSData *data = [orignal dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrypted = [self RSAEncryptWithData:data usingPublicKey:YES];
    return [encrypted base64Encoding] ;
}
@end
