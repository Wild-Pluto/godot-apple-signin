# Example of use

```gdscript
extends Node2D

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
	
func _apple_id_get_credential_success(result):
	print_debug(result)
	
func _apple_id_get_credential_error(result):
	print_debug(result)
```
