#include "AppleAuth.h"
#include "GodotAppleId.h"
#import "app_delegate.h"
#import "io/json.h"

#if VERSION_MAJOR == 3
#define CLASS_DB ClassDB
#else
#define CLASS_DB ObjectTypeDB
#endif

GodotAppleId::GodotAppleId() {
}

GodotAppleId::~GodotAppleId() {
    [[AppleAuthManager sharedManager] release];
}

void GodotAppleId::set_callback_id(int instance_id) {
    GodotAppleId::_callback_id = instance_id;
}

bool GodotAppleId::is_current_platform_supported() {
    if (@available(iOS 13.0, tvOS 13.0, macOS 10.15, *))
    {
        return true;
    }
    else
    {
        return false;
    }
}

void GodotAppleId::login(int options, const Variant &c_nonce) {
    NSString *nonce = !c_nonce.is_zero() ? [NSString stringWithCString:String(c_nonce).utf8().get_data() encoding:NSUTF8StringEncoding] : nil;
    [[AppleAuthManager sharedManager] loginWithAppleId:^(const char *result, bool error) {
        GodotAppleId::_send_result_to_engine(result, error, "_apple_id_login_success", "_apple_id_login_error");
    } withOptions:options andNonce:nonce];
}

void GodotAppleId::quick_login(const Variant &c_nonce) {
    NSString *nonce = !c_nonce.is_zero() ? [NSString stringWithCString:String(c_nonce).utf8().get_data() encoding:NSUTF8StringEncoding] : nil;
    [[AppleAuthManager sharedManager] quickLogin:^(const char *result, bool error) {
        GodotAppleId::_send_result_to_engine(result, error, "_apple_id_login_success", "_apple_id_login_error");
    } withNonce:nonce];
}

void GodotAppleId::get_credential_state(const String user_id) {
    [[AppleAuthManager sharedManager] getCredentialStateForUser:[NSString stringWithCString:String(user_id).utf8().get_data() encoding:NSUTF8StringEncoding]
        withCallback:^(const char *result, bool error) {
            GodotAppleId::_send_result_to_engine(result, error, "_apple_id_get_credential_success", "_apple_id_get_credential_error");
        }
     ];
}

void GodotAppleId::_send_result_to_engine(const char *result, bool error, const String &succes_hook, const String &error_hook) {
    Variant godot_result = Variant();
    
    if (result) {
        String errs;
        int errl;
        
        JSON::parse(*(new String(result)), godot_result, errs, errl);
    }
    
    if (error) {
        Object *obj = ObjectDB::get_instance(GodotAppleId::_callback_id);
        obj->call_deferred(error_hook, godot_result);
    } else {
        Object *obj = ObjectDB::get_instance(GodotAppleId::_callback_id);
        obj->call_deferred(succes_hook, godot_result);
    }
}

void GodotAppleId::_bind_methods() {
    CLASS_DB::bind_method("is_current_platform_supported", &GodotAppleId::is_current_platform_supported);
    CLASS_DB::bind_method("login", &GodotAppleId::login);
    CLASS_DB::bind_method("quick_login", &GodotAppleId::quick_login);
    CLASS_DB::bind_method("get_credential_state", &GodotAppleId::get_credential_state);
}
