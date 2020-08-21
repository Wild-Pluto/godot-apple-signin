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

#import "AppleAuthSerializer.h"

@implementation AppleAuthSerializer

+ (NSDictionary *) dictionaryForNSError:(NSError *)error
{
    if (!error)
        return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:@([error code]) forKey:@"code"];
    [result setValue:[error domain] forKey:@"domain"];
    [result setValue:[error localizedDescription] forKey:@"localized_description"];
    [result setValue:[error localizedRecoveryOptions] forKey:@"localized_recovery_options"];
    [result setValue:[error localizedRecoverySuggestion] forKey:@"localized_recovery_suggestion"];
    [result setValue:[error localizedFailureReason] forKey:@"localized_failure_reason"];
    return [result copy];
}

+ (NSDictionary *) credentialResponseDictionaryForCredentialState:(NSNumber *)credentialStateNumber
                                                  errorDictionary:(NSDictionary *)errorDictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result setValue:@(errorDictionary == nil) forKey:@"success"];
    [result setValue:@(credentialStateNumber != nil) forKey:@"has_credential_state"];
    [result setValue:@(errorDictionary != nil) forKey:@"has_error"];
    
    [result setValue:credentialStateNumber forKey:@"credential_state"];
    [result setValue:errorDictionary forKey:@"error"];
    
    return [result copy];
}

+ (NSDictionary *) loginResponseDictionaryForAppleIdCredentialDictionary:(NSDictionary *)appleIdCredentialDictionary
                                            passwordCredentialDictionary:(NSDictionary *)passwordCredentialDictionary
                                                         errorDictionary:(NSDictionary *)errorDictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result setValue:@(errorDictionary == nil) forKey:@"success"];
    [result setValue:@(appleIdCredentialDictionary != nil) forKey:@"has_apple_id_credential"];
    [result setValue:@(passwordCredentialDictionary != nil) forKey:@"has_password_credential"];
    [result setValue:@(errorDictionary != nil) forKey:@"has_error"];
    
    [result setValue:appleIdCredentialDictionary forKey:@"apple_id_credential"];
    [result setValue:passwordCredentialDictionary forKey:@"password_credential"];
    [result setValue:errorDictionary forKey:@"error"];
    
    return [result copy];
}

// IOS/TVOS 9.0 | MACOS 10.11
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000 || __TV_OS_VERSION_MAX_ALLOWED >= 90000 || __MAC_OS_X_VERSION_MAX_ALLOWED >= 101100

+ (NSDictionary *) dictionaryForNSPersonNameComponents:(NSPersonNameComponents *)nameComponents
{
    if (!nameComponents)
        return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:[nameComponents namePrefix] forKey:@"name_prefix"];
    [result setValue:[nameComponents givenName] forKey:@"given_ame"];
    [result setValue:[nameComponents middleName] forKey:@"middle_name"];
    [result setValue:[nameComponents familyName] forKey:@"family_name"];
    [result setValue:[nameComponents nameSuffix] forKey:@"name_suffix"];
    [result setValue:[nameComponents nickname] forKey:@"nickname"];
    
    NSDictionary *phoneticRepresentationDictionary = [AppleAuthSerializer dictionaryForNSPersonNameComponents:[nameComponents phoneticRepresentation]];
    [result setValue:@(phoneticRepresentationDictionary != nil) forKey:@"has_phonetic_representation"];
    [result setValue:phoneticRepresentationDictionary forKey:@"phonetic_representation"];
    
    return [result copy];
}

#endif

// IOS/TVOS 13.0 | MACOS 10.15
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 || __TV_OS_VERSION_MAX_ALLOWED >= 130000 || __MAC_OS_X_VERSION_MAX_ALLOWED >= 101500

+ (NSDictionary *) dictionaryForASAuthorizationAppleIDCredential:(ASAuthorizationAppleIDCredential *)appleIDCredential
{
    if (!appleIDCredential)
        return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:[[appleIDCredential identityToken] base64EncodedStringWithOptions:0] forKey:@"identityToken"];
    [result setValue:[[appleIDCredential authorizationCode] base64EncodedStringWithOptions:0] forKey:@"authorizationCode"];
    [result setValue:[appleIDCredential state] forKey:@"state"];
    [result setValue:[appleIDCredential user] forKey:@"user"];
    [result setValue:[appleIDCredential authorizedScopes] forKey:@"authorizedScopes"];
    [result setValue:[appleIDCredential email] forKey:@"email"];
    [result setValue:@([appleIDCredential realUserStatus]) forKey:@"realUserStatus"];
    
    NSDictionary *fullNameDictionary = [AppleAuthSerializer dictionaryForNSPersonNameComponents:[appleIDCredential fullName]];
    [result setValue:@(fullNameDictionary != nil) forKey:@"hasFullName"];
    [result setValue:fullNameDictionary forKey:@"fullName"];
    
    return [result copy];
}

+ (NSDictionary *) dictionaryForASPasswordCredential:(ASPasswordCredential *)passwordCredential
{
    if (!passwordCredential)
        return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:[passwordCredential user] forKey:@"user"];
    [result setValue:[passwordCredential password] forKey:@"password"];
    return [result copy];
}

#endif

@end
