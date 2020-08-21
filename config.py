def can_build(env, platform):
    return platform=="iphone"

def configure(env):
    env.Append(CPPPATH=['#core'])
    env.Append(LINKFLAGS=['-ObjC', '-framework', 'AuthenticationServices', '-framework', 'Foundation', '-framework', 'UIKit'])
