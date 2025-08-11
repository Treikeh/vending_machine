extends Achievement
class_name BuyEverythingAchievement


var items_bought: Dictionary = {
	"11": false,
	"12": false,
	"13": false,
	"14": false,
	"21": false,
	"41": false,
}


func item_bought(item_code: String) -> void:
	if not items_bought[item_code]:
		items_bought[item_code] = true
		add_points(1)


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"points": current_points,
		"completed": _completed,
		"items_bought": items_bought,
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		current_points = data.points
		_completed = data.completed
		items_bought = data.items_bought
