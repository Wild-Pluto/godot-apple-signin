//
//  godot_plugin.m
//  godot_plugin
//
//  Created by Sergey Minakov on 14.08.2020.
//  Copyright © 2020 Godot. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "godot_plugin.h"
#include "godot_plugin_implementation.h"

#include "core/engine.h"

GodotAppleSignIn *plugin;

void godot_apple_signin_init() {
    plugin = memnew(GodotAppleSignIn);
    Engine::get_singleton()->add_singleton(Engine::Singleton(PLUGIN_NAME, plugin));
}

void godot_apple_signin_deinit() {
    if (plugin) {
       memdelete(plugin);
   }
}
