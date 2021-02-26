#ifndef godot_plugin_implementation_h
#define godot_plugin_implementation_h

#include "AppleAuth.h"
#include "core/object.h"
#include "io/json.h"
#include "godot_plugin.h"
#include "core/engine.h"

class GodotAppleSignIn : public Object {
    GDCLASS(GodotAppleSignIn, Object);
    
    static void _bind_methods();
    static void _send_result_to_engine(const char *result, bool error, const String &succes_hook, const String &error_hook);
    
public:
    
    bool is_current_platform_supported();
    void login(bool withEmail, bool withName, const Variant &nonce);
    void quick_login(const Variant &nonce);
    void get_credential_state(const String user_id);
    
    GodotAppleSignIn();
    ~GodotAppleSignIn();
};

#endif
