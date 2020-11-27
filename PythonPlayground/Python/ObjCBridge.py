from rubicon.objc.api import ObjCClass

bridge = ObjCClass("PythonPlayground.PythonBridge").alloc().init()

def input(prompt):
    return str(bridge.input(prompt))
