//
//  MIT License
//
//  Copyright (c) 2019 Daniel Lupiañez Casares
//  Copyright (c) 2020 Arthur devolonter Bikmullin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "AppleAuth.h"
#import "AppleAuthSerializer.h"
#import <AuthenticationServices/AuthenticationServices.h>


#pragma mark - AppleAuthManager Implementation

// IOS/TVOS 13.0 | MACOS 10.15
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 || __TV_OS_VERSION_MAX_ALLOWED >= 130000 || __MAC_OS_X_VERSION_MAX_ALLOWED >= 101500
#define AUTHENTICATION_SERVICES_AVAILABLE true
#import <AuthenticationServices/AuthenticationServices.h>
#endif

@interface AppleAuthManager ()
- (const char *) getPayloadString:(NSDictionary *)payloadDictionary;
@end

#if AUTHENTICATION_SERVICES_AVAILABLE
API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface AppleAuthManager () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
@property (nonatomic, strong) ASAuthorizationAppleIDProvider *appleIdProvider;
@property (nonatomic, strong) ASAuthorizationPasswordProvider *passwordProvider;
@property (nonatomic, strong) NSObject *credentialsRevokedObserver;
@property (nonatomic, strong) NSMutableDictionary *authorizationsInProgress;
@end
#endif

@implementation AppleAuthManager

+ (instancetype) sharedManager
{
    static AppleAuthManager *_defaultManager = nil;
    static dispatch_once_t defaultManagerInitialization;
    
    dispatch_once(&defaultManagerInitialization, ^{
        _defaultManager = [[AppleAuthManager alloc] init];
    });
    
    return _defaultManager;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
#if AUTHENTICATION_SERVICES_AVAILABLE
        if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
        {
            _appleIdProvider = [[ASAuthorizationAppleIDProvider alloc] init];
            _passwordProvider = [[ASAuthorizationPasswordProvider alloc] init];
            _authorizationsInProgress = [[NSMutableDictionary alloc] init];
        }
#endif
    }
    return self;
}

#pragma mark Public methods

- (void) quickLogin:(GodotCallback)callback withNonce:(NSString *)nonce
{
#if AUTHENTICATION_SERVICES_AVAILABLE
    if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
    {
        ASAuthorizationAppleIDRequest *appleIDRequest = [[self appleIdProvider] createRequest];
        [appleIDRequest setNonce:nonce];
    
        ASAuthorizationPasswordRequest *keychainRequest = [[self passwordProvider] createRequest];
    
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest, keychainRequest]];
        [self performAuthorizationRequestsForController:authorizationController withCallback:callback];
    }
    else
    {
        callback(nil, true);
    }
#else
    callback(nil, true);
#endif
}

- (void) loginWithAppleId:(GodotCallback)callback withOptions:(AppleAuthManagerLoginOptions)options andNonce:(NSString *)nonce
{
#if AUTHENTICATION_SERVICES_AVAILABLE
    if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
    {
        ASAuthorizationAppleIDRequest *request = [[self appleIdProvider] createRequest];
        NSMutableArray *scopes = [NSMutableArray array];
        
        if (options & AppleAuthManagerIncludeName)
            [scopes addObject:ASAuthorizationScopeFullName];
            
        if (options & AppleAuthManagerIncludeEmail)
            [scopes addObject:ASAuthorizationScopeEmail];
        
        [request setRequestedScopes:[scopes copy]];
        [request setNonce:nonce];
        
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        [self performAuthorizationRequestsForController:authorizationController withCallback:callback];
    }
    else
    {
        callback(nil, true);
    }
#else
    callback(nil, true);
#endif
}


- (void) getCredentialStateForUser:(NSString *)userId withCallback:(GodotCallback)callback
{
#if AUTHENTICATION_SERVICES_AVAILABLE
    if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
    {
        [[self appleIdProvider] getCredentialStateForUserID:userId completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
            NSNumber *credentialStateNumber = nil;
            NSDictionary *errorDictionary = nil;
        
            if (error)
                errorDictionary = [AppleAuthSerializer dictionaryForNSError:error];
            else
                credentialStateNumber = @(credentialState);
        
            NSDictionary *responseDictionary = [AppleAuthSerializer credentialResponseDictionaryForCredentialState:credentialStateNumber
                                                                                               errorDictionary:errorDictionary];
        
            callback([self getPayloadString:responseDictionary], error);
        }];
    }
    else
    {
        callback(nil, true);
    }
#else
    callback(nil, true);
#endif
}

- (void) registerCredentialsRevokedCallbackForRequestId:(GodotCallback)callback
{
#if AUTHENTICATION_SERVICES_AVAILABLE
    if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
    {
        if ([self credentialsRevokedObserver])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:[self credentialsRevokedObserver]];
            [self setCredentialsRevokedObserver:nil];
        }
        
        if (callback)
        {
            NSObject *observer = [[NSNotificationCenter defaultCenter] addObserverForName:ASAuthorizationAppleIDProviderCredentialRevokedNotification
                                                                               object:nil
                                                                                queue:nil
                                                                           usingBlock:^(NSNotification * _Nonnull note) {
                                                                                callback(nil, false);
                                                                           }];
            [self setCredentialsRevokedObserver:observer];
        }
    }
#endif
}

#pragma mark Private methods

- (const char *) getPayloadString:(NSDictionary *)payloadDictionary
{
    NSError *error = nil;
    NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payloadDictionary options:0 error:&error];
    NSString *payloadString = error ? NULL : [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
    return [payloadString UTF8String];
}

#if AUTHENTICATION_SERVICES_AVAILABLE

- (void) performAuthorizationRequestsForController:(ASAuthorizationController *)authorizationController withCallback:(GodotCallback)callback
API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
{
    NSValue *authControllerAsKey = [NSValue valueWithNonretainedObject:authorizationController];
    [[self authorizationsInProgress] setObject:[callback copy] forKey:authControllerAsKey];
    
    [authorizationController setDelegate:self];
    [authorizationController setPresentationContextProvider:self];
    [authorizationController performRequests];
}

#pragma mark ASAuthorizationControllerDelegate protocol implementation

- (void) authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization
API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
{
    NSValue *authControllerAsKey = [NSValue valueWithNonretainedObject:controller];
    GodotCallback callback = [[self authorizationsInProgress] objectForKey:authControllerAsKey];
    
    if (callback)
    {
        NSDictionary *appleIdCredentialDictionary = nil;
        NSDictionary *passwordCredentialDictionary = nil;
        if ([[authorization credential] isKindOfClass:[ASAuthorizationAppleIDCredential class]])
        {
            appleIdCredentialDictionary = [AppleAuthSerializer dictionaryForASAuthorizationAppleIDCredential:(ASAuthorizationAppleIDCredential *)[authorization credential]];
        }
        else if ([[authorization credential] isKindOfClass:[ASPasswordCredential class]])
        {
            passwordCredentialDictionary = [AppleAuthSerializer dictionaryForASPasswordCredential:(ASPasswordCredential *)[authorization credential]];
        }

        NSDictionary *responseDictionary = [AppleAuthSerializer loginResponseDictionaryForAppleIdCredentialDictionary:appleIdCredentialDictionary
                                                                                      passwordCredentialDictionary:passwordCredentialDictionary
                                                                                                   errorDictionary:nil];
        
        callback([self getPayloadString:responseDictionary], false);
        [[self authorizationsInProgress] removeObjectForKey:authControllerAsKey];
    }
}

- (void) authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error
API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
{
    NSValue *authControllerAsKey = [NSValue valueWithNonretainedObject:controller];
    GodotCallback callback = [[self authorizationsInProgress] objectForKey:authControllerAsKey];
    
    if (callback)
    {
        NSDictionary *errorDictionary = [AppleAuthSerializer dictionaryForNSError:error];
        NSDictionary *responseDictionary = [AppleAuthSerializer loginResponseDictionaryForAppleIdCredentialDictionary:nil
                                                                                         passwordCredentialDictionary:nil
                                                                                                      errorDictionary:errorDictionary];
        
        callback([self getPayloadString:responseDictionary], true);
        [[self authorizationsInProgress] removeObjectForKey:authControllerAsKey];
    }
}

#pragma mark ASAuthorizationControllerPresentationContextProviding protocol implementation

- (ASPresentationAnchor) presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller
API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 || __TV_OS_VERSION_MAX_ALLOWED >= 130000
        return [[[UIApplication sharedApplication] delegate] window];
    #elif __MAC_OS_X_VERSION_MAX_ALLOWED >= 101500
        return [[NSApplication sharedApplication] mainWindow];
    #else
        return nil;
    #endif
}

#endif

@end
