Code of this module based on [apple-signin-unity
](https://github.com/lupidan/apple-signin-unity)

# Functions

```gdscript
set_callback_id(instance_id:int) -> void
is_current_platform_supported() -> bool
login(int options, nonce:Variant) -> void
quick_login(nonce:Variant) -> void
get_credential_state(user_id:String) -> void
```

# Callbacks

```gdscript
func _apple_id_login_success(result):
	pass
	
func _apple_id_login_error(result):
	pass
	
func _apple_id_get_credential_success(result):
	pass
	
func _apple_id_get_credential_error(result):
	pass
```

# Example of use

```gdscript
extends Node

enum {
	FULL_NAME = 1 << 0,
	EMAIL = 1 << 1,
}

func _ready():
	if Engine.has_singleton("GodotAppleId"):
		var apple = Engine.get_singleton("GodotAppleId")
		apple.set_callback_id(get_instance_id())
		apple.login(FULL_NAME | EMAIL, null)
		
func _apple_id_login_success(result):
	print_debug(result)
	
func _apple_id_login_error(result):
	print_debug(result)
```

# Requirements

- UiKit.framework
- Foundation.framework
- AuthenticationServices.framework
- Sign in with Apple capability
