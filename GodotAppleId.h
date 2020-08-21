#ifndef GODOT_APPLE_ID_H
#define GODOT_APPLE_ID_H

#include <version_generated.gen.h>
#include "reference.h"

class GodotAppleId : public Reference {
    
#if VERSION_MAJOR == 3
    GDCLASS(GodotAppleId, Reference);
#else
    OBJ_TYPE(GodotAppleId, Reference);
#endif

protected:
    static int _callback_id;
    
    static void _bind_methods();
    static void _send_result_to_engine(const char *result, bool error, const String &succes_hook, const String &error_hook);

public:
    
    void set_callback_id(int instance_id);
    bool is_current_platform_supported();
    void login(int options, const Variant &nonce);
    void quick_login(const Variant &nonce);
    void get_credential_state(const String user_id);

    GodotAppleId();
    ~GodotAppleId();
};

#endif
