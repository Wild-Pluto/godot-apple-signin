#import <Foundation/Foundation.h>

#include "core/project_settings.h"
#include "core/class_db.h"
#include "godot_plugin.h"
#include "godot_plugin_implementation.h"

void GodotAppleSignIn::_bind_methods() {
    ClassDB::bind_method(D_METHOD("is_current_platform_supported"), &GodotAppleSignIn::is_current_platform_supported);
    ClassDB::bind_method(D_METHOD("login"), &GodotAppleSignIn::login);
    ClassDB::bind_method(D_METHOD("quick_login"), &GodotAppleSignIn::quick_login);
    ClassDB::bind_method(D_METHOD("get_credential_state"), &GodotAppleSignIn::get_credential_state);
    
    ADD_SIGNAL(MethodInfo(SIGNAL_LOGIN_SUCCESS, PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo(SIGNAL_LOGIN_ERROR, PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo(SIGNAL_CREDENTIAL_SUCCESS, PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo(SIGNAL_CREDENTIAL_ERROR, PropertyInfo(Variant::DICTIONARY, "result")));
}

bool GodotAppleSignIn::is_current_platform_supported() {
    if (@available(iOS 13.0, *)) {
        return true;
    }
    
    return false;
}

void GodotAppleSignIn::login(bool withEmail, bool withName, const Variant &c_nonce) {
    AppleAuthManagerLoginOptions options = 0;
    
    if (withName) {
        options |= AppleAuthManagerIncludeName;
    }
    
    if (withEmail) {
        options |= AppleAuthManagerIncludeEmail;
    }
    
    NSString *nonce = !c_nonce.is_zero() ? [NSString stringWithCString:String(c_nonce).utf8().get_data() encoding:NSUTF8StringEncoding] : nil;
    [[AppleAuthManager sharedManager] loginWithAppleId:^(const char *result, bool error) {
        GodotAppleSignIn::_send_result_to_engine(result, error, SIGNAL_LOGIN_SUCCESS, SIGNAL_LOGIN_ERROR);
    } withOptions:options andNonce:nonce];
}

void GodotAppleSignIn::quick_login(const Variant &c_nonce) {
    NSString *nonce = !c_nonce.is_zero() ? [NSString stringWithCString:String(c_nonce).utf8().get_data() encoding:NSUTF8StringEncoding] : nil;
    [[AppleAuthManager sharedManager] quickLogin:^(const char *result, bool error) {
        GodotAppleSignIn::_send_result_to_engine(result, error, SIGNAL_LOGIN_SUCCESS, SIGNAL_LOGIN_ERROR);
    } withNonce:nonce];
}

void GodotAppleSignIn::get_credential_state(const String user_id) {
    [[AppleAuthManager sharedManager] getCredentialStateForUser:[NSString stringWithCString:String(user_id).utf8().get_data() encoding:NSUTF8StringEncoding]
        withCallback:^(const char *result, bool error) {
        GodotAppleSignIn::_send_result_to_engine(result, error, SIGNAL_CREDENTIAL_SUCCESS, SIGNAL_CREDENTIAL_ERROR);
        }
     ];
}

void GodotAppleSignIn::_send_result_to_engine(const char *result, bool error, const String &succes_hook, const String &error_hook) {
    Variant godot_result = Variant();
    
    if (result) {
        String errs;
        int errl;
        
        JSON::parse(*(new String(result)), godot_result, errs, errl);
    }
    
    error ? Engine::get_singleton()->get_singleton_object(PLUGIN_NAME)->emit_signal(error_hook, godot_result) :
        Engine::get_singleton()->get_singleton_object(PLUGIN_NAME)->emit_signal(succes_hook, godot_result);
}

GodotAppleSignIn::GodotAppleSignIn() {
}

GodotAppleSignIn::~GodotAppleSignIn() {
}
