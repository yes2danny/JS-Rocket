class_name LogEntry
extends Resource
## A single crew log entry. Stored as .tres files in resources/logs/.

@export var log_id: String = ""
@export var title: String = ""
@export var author: String = ""
@export var date: String = ""
@export var content: String = ""
@export var category: String = ""  # "early", "middle", "late", "final"
@export var sort_order: int = 0
