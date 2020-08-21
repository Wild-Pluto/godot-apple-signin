#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(int, AppleAuthManagerLoginOptions) {
    AppleAuthManagerIncludeName = 1 << 0,
    AppleAuthManagerIncludeEmail = 1 << 1,
};

typedef void (*NativeMessageHandlerDelegate)(uint requestId, const char* payload);
typedef void (^ GodotCallback)(const char *result, bool);

@interface AppleAuthManager : NSObject

+ (instancetype) sharedManager;

- (void) quickLogin:(GodotCallback)callback withNonce:(NSString *)nonce;
- (void) loginWithAppleId:(GodotCallback)callback withOptions:(AppleAuthManagerLoginOptions)options andNonce:(NSString *)nonce;
- (void) getCredentialStateForUser:(NSString *)userId withCallback:(GodotCallback)callback;
- (void) registerCredentialsRevokedCallbackForRequestId:(uint)requestId;

@end

NS_ASSUME_NONNULL_END
