//
// 


#import "ZMServerTrust.h"
@import WireSystem;
#import <mach-o/dyld.h>

// To dump certificate data, use
//     CFIndex const certCount = SecTrustGetCertificateCount(serverTrust);
// and
//     SecCertificateRef cert0 = SecTrustGetCertificateAtIndex(serverTrust, 0);
//     SecCertificateRef cert1 = SecTrustGetCertificateAtIndex(serverTrust, 1);
// etc. and then
//     SecCertificateCopyData(cert1)
// to dump the certificate data.
//
//
// Also
//     CFBridgingRelease(SecCertificateCopyValues(cert1, @[kSecOIDX509V1SubjectName], NULL))

/// Returns the public key of the leaf certificate associated with the trust object
static SecKeyRef publicKeyAssociatedWithServerTrust(SecTrustRef const serverTrust)
{
    SecKeyRef key = nil;
    __block SecPolicyRef policy = SecPolicyCreateBasicX509();
    
    __block SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0); // leaf certificate
    
    SecCertificateRef certificatesCArray[] = { certificate};
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)certificatesCArray, 1, NULL);
    __block SecTrustRef trust = NULL;
    
    void(^finally)(void) = ^{
        if (certificates) {
            CFRelease(certificates);
        }
        
        if (trust) {
            CFRelease(trust);
        }
        
        CFRelease(policy);
    };
    
    if (SecTrustCreateWithCertificates(certificates, policy, &trust) != noErr) {
        finally();
        return nil;
    }
    
    SecTrustResultType result;
    if (SecTrustEvaluate(trust, &result) != noErr) {
        finally();
        return nil;
    }
    
    key = SecTrustCopyPublicKey(trust);
        
    finally();
    
    return key;
}

__nullable SecKeyRef _SecCertificateCopyPublicKey(__nonnull SecCertificateRef certificate)
{
    return SecCertificateCopyPublicKey(certificate);
}

BOOL verifyServerTrustWithPinnedKeys(SecTrustRef const serverTrust, NSArray *pinnedKeys)
{    
    SecTrustResultType result;
    if (SecTrustEvaluate(serverTrust, &result) != noErr) {
        return NO;
    }
    
    if (result != kSecTrustResultProceed && result != kSecTrustResultUnspecified) {
        return NO;
    }
    
    if (pinnedKeys.count == 0) {
        return YES;
    }
    
    SecKeyRef publicKey = publicKeyAssociatedWithServerTrust(serverTrust);
    
    if (publicKey == nil) {
        return NO;
    }
    
    for (id pinnedKey in pinnedKeys) {
        if ([(__bridge id)publicKey isEqual:pinnedKey]) {
            CFRelease(publicKey);
            return YES;
        }
    }
    
    CFRelease(publicKey);
    return NO;
}
