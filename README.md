Code of this module based on [apple-signin-unity
](https://github.com/lupidan/apple-signin-unity)

## Methods

```gdscript
is_current_platform_supported() -> bool
login(with_email:bool, with_name:bool, nonce:Variant) -> void
quick_login(nonce:Variant) -> void
get_credential_state(user_id:String) -> void
```

## Signals

```gdscript
login_success(result:Dictionary)
login_error(result:Dictionary)
credential_success(result:Dictionary)
credential_error(result:Dictionary)
```

## Example of use

```gdscript
extends Node

var apple_sign_in:Object

func _ready():
	if Engine.has_singleton("GodotAppleSignIn"):
		apple_sign_in = Engine.get_singleton("GodotAppleSignIn")
		
		apple_sign_in.connect("login_success", self, "_on_login_success")
		apple_sign_in.connect("login_error", self, "_on_login_error")
		apple_sign_in.connect("credential_success", self, "_on_credential_success")
		apple_sign_in.connect("credential_error", self, "_on_credential_error")
		
	if !apple_sign_in or !apple_sign_in.is_current_platform_supported():
		return
	
#	generate nonce
	randomize()
	var key := PoolByteArray()
	for i in 32:
		key.append(randi() % 256)
		
	var nonce := key.hex_encode()
	
#	with email and name
	apple_sign_in.login(true, true, nonce)
	
func _on_login_success(result):
	print(result)
	
func _on_login_error(result):
	print(result)
	
func _on_credential_success(result):
	print(result)
	
func _on_credential_error(result):
	print(result)
```

## Requirements

Sign in with Apple capability

---
For Godot less than v3.2.4 use [3.x](https://github.com/Wild-Pluto/godot-apple-signin/tree/3.x) branch
