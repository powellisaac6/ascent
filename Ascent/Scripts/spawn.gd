extends Area2D

class_name Respawn

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# add to the game managers respawns
		if self not in GameManager.spawn_points:
			print("spawn saved")
			GameManager.spawn_points.append(self)
