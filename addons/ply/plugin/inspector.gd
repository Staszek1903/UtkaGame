tool
extends EditorInspectorPlugin

const PlyEditor = preload("../nodes/ply.gd")
const InspectorControl = preload("../gui/inspector/inspector.tscn")

var plugin

func _init(p):
    plugin = p

func can_handle(o: Object):
    return o is PlyEditor

func parse_begin(o: Object):
    var inst = InspectorControl.instance()
    inst.plugin = plugin
    add_custom_control(inst)