class_name LogDatabase
extends RefCounted
## Static data accessor for crew log entries. Auto-loads all .tres from resources/logs/.

static var _logs: Dictionary = {}
static var _loaded: bool = false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	var dir := DirAccess.open("res://resources/logs/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var entry = load("res://resources/logs/" + file_name)
				if entry is LogEntry:
					_logs[entry.log_id] = entry
			file_name = dir.get_next()
		dir.list_dir_end()
	_loaded = true


static func get_log(log_id: String) -> LogEntry:
	_ensure_loaded()
	return _logs.get(log_id, null)


static func get_all_logs_sorted() -> Array:
	_ensure_loaded()
	var arr := _logs.values()
	arr.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	return arr


static func get_total_count() -> int:
	_ensure_loaded()
	return _logs.size()
