#define PLUGIN_NAME String("GodotAppleSignIn")

#define SIGNAL_LOGIN_SUCCESS "login_success"
#define SIGNAL_LOGIN_ERROR "login_error"
#define SIGNAL_CREDENTIAL_SUCCESS "credential_success"
#define SIGNAL_CREDENTIAL_ERROR "credential_error"

void godot_apple_signin_init();
void godot_apple_signin_deinit();
