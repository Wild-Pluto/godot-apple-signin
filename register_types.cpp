#include <version_generated.gen.h>

#if VERSION_MAJOR == 3
#include <core/class_db.h>
#include <core/engine.h>
#else
#include "object_type_db.h"
#include "core/globals.h"
#endif

#include "register_types.h"
#include "GodotAppleId.h"

void register_godot_apple_id_types() {
#if VERSION_MAJOR == 3
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotAppleId", memnew(GodotAppleId)));
#else
    Globals::get_singleton()->add_singleton(Globals::Singleton("GodotAppleId", memnew(GodotAppleId)));
#endif
}

void unregister_godot_apple_id_types() {
}
