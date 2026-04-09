extends Node
## Central game state authority. Tracks logs found, conditions met, and scene transitions.

signal log_collected(log_id: String)
signal condition_changed(key: String, value: bool)

var collected_logs: Dictionary = {}
var conditions: Dictionary = {}


func collect_log(log_id: String) -> void:
	if log_id in collected_logs:
		return
	collected_logs[log_id] = true
	log_collected.emit(log_id)


func has_log(log_id: String) -> bool:
	return log_id in collected_logs


func get_log_count() -> int:
	return collected_logs.size()


func set_condition(key: String, value: bool) -> void:
	conditions[key] = value
	condition_changed.emit(key, value)


func has_condition(key: String) -> bool:
	return conditions.get(key, false)


func reset_state() -> void:
	collected_logs.clear()
	conditions.clear()
