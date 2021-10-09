#!/bin/bash

name=libgodot_apple_signin
version=3.3.4-stable
declare -a targets=("release" "release_debug")

while getopts v: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
        *) echo "default version is $version";;
    esac
done
cd ./godot || exit
git checkout "$version"
./../scripts/timeout.sh scons platform=iphone target=debug --jobs=$(sysctl -n hw.logicalcpu)
cd ../

for target in "${targets[@]}"
do
  scons platform=ios arch=arm64 target="$target" target_name=$name version=3.2 --jobs=$(sysctl -n hw.logicalcpu)
  scons platform=ios simulator=on arch=x86_64 target="$target" target_name=$name version=3.2 --jobs=$(sysctl -n hw.logicalcpu)

  output="release"
  if [ "$target" = "release_debug" ]; then
    output="debug"
  fi
  lipo -create bin/$name.arm64-iphone."$target".a bin/$name.x86_64-simulator."$target".a -output bin/$name.$output.a
  rm bin/$name.arm64-iphone."$target".a
  rm bin/$name.x86_64-simulator."$target".a
done

zip dist/Prebuilt.plugin.for.Godot.v"$version".zip bin/$name.release.a bin/$name.debug.a ./godot_apple_signin.gdip