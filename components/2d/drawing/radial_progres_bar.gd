@icon("res://assets/class_icons/gi_radial_progress_bar.svg")
@tool class_name RadialProgressBar extends Range

enum EndOverlap {BELOW = -1, COMBINE = 0, ABOVE = 1}

@export var radius: float = 16:
	set(v):
		radius = v
		queue_redraw()
@export_range(0, 360, .01, "radians_as_degrees") var start_direction: float:
	set(v):
		start_direction = v
		queue_redraw()
@export_range(0, 360, .01, "radians_as_degrees") var end_direction: float = PI*2:
	set(v):
		end_direction = v
		queue_redraw()
@export_tool_button("Redraw", "Edit") var btn_redraw := queue_redraw

@export_group("Bar", "bar_")
@export var bar_width: float = 2:
	set(v):
		if start_radius == bar_width:
			start_radius = v
		if end_radius == bar_width:
			end_radius = v
		bar_width = v
		queue_redraw()
@export var bar_color: Color = Color.WHITE:
	set(v):
		bar_color = v
		queue_redraw()
@export var bar_point_count: int = 50:
	set(v):
		bar_point_count = v
		queue_redraw()
@export var bar_antialiased: bool = false:
	set(v):
		bar_antialiased = v
		queue_redraw()
@export_subgroup("Outline", "bar_outline_")
@export var bar_outline_width: float:
	set(v):
		if bar_outline_width == start_outline_width:
			start_outline_width = v
		if bar_outline_width == end_outline_width:
			end_outline_width = v
		bar_outline_width = v
		queue_redraw()
@export var bar_outline_color: Color = Color.TRANSPARENT:
	set(v):
		bar_outline_color = v
		queue_redraw()

@export_group("Start", "start_")
@export var start_enabled: bool = false:
	set(v):
		start_enabled = v
		queue_redraw()
@export var start_overlap: EndOverlap:
	set(v):
		start_overlap = v
		queue_redraw()
@export var start_radius: float = -1:
	set(v):
		start_radius = v
		queue_redraw()
@export var start_color: Color = Color.WHITE:
	set(v):
		start_color = v
		queue_redraw()
@export var start_antialiased: bool = false:
	set(v):
		start_antialiased = v
		queue_redraw()
@export_subgroup("Outline", "start_outline_")
@export var start_outline_width: float:
	set(v):
		start_outline_width = v
		queue_redraw()
@export var start_outline_color: Color = Color.TRANSPARENT:
	set(v):
		start_outline_color = v
		queue_redraw()

@export_group("End", "end_")
@export var end_enabled: bool = false:
	set(v):
		end_enabled = v
		queue_redraw()
@export var end_overlap: EndOverlap:
	set(v):
		end_overlap = v
		queue_redraw()
@export var end_radius: float = -1:
	set(v):
		end_radius = v
		queue_redraw()
@export var end_color: Color = Color.WHITE:
	set(v):
		end_color = v
		queue_redraw()
@export var end_antialiased: bool = false:
	set(v):
		end_antialiased = v
		queue_redraw()
@export_subgroup("Outline", "end_outline_")
@export var end_outline_width: float:
	set(v):
		end_outline_width = v
		queue_redraw()
@export var end_outline_color: Color = Color.TRANSPARENT:
	set(v):
		end_outline_color = v
		queue_redraw()

func _get_minimum_size() -> Vector2:
	return Vector2.ONE * (radius * 2 + bar_width)

func _draw() -> void:
	update_minimum_size()
	if value != min_value:
		var end_angle := remap(value, min_value, max_value, start_direction, end_direction)
		var bar_center := Vector2.ONE * (radius + bar_width / 2)
		var start_center := Vector2.ONE * (radius + bar_width / 2) + Vector2.from_angle(start_direction) * radius
		var end_center := Vector2.ONE * (radius + bar_width / 2) + Vector2.from_angle(end_angle) * (radius)
		if start_overlap != EndOverlap.ABOVE and start_enabled: # start outline when below or combine
			draw_circle(
				start_center,
				start_radius * 2,
				start_outline_color,
				false, start_outline_width * 2, start_antialiased
			)
		if start_overlap == EndOverlap.BELOW and start_enabled: # start when below
			draw_circle(
				start_center,
				start_radius * 2,
				start_color,
				true, -1, start_antialiased
			)
		if end_overlap != EndOverlap.ABOVE and end_enabled: # end outline when below or combine
			draw_circle(
				end_center,
				end_radius * 2,
				end_outline_color,
				false, end_outline_width * 2, end_antialiased
			)
		if end_overlap == EndOverlap.BELOW and end_enabled: # end when below
			draw_circle(
				end_center,
				end_radius * 2,
				end_color,
				true, -1, end_antialiased
			)
		# bar outline
		draw_arc(
			bar_center,
			radius,
			start_direction,
			end_angle,
			bar_point_count,
			bar_outline_color, bar_width + (bar_outline_width * 2), bar_antialiased
		)
		# bar
		draw_arc(
			bar_center,
			radius,
			start_direction,
			end_angle,
			bar_point_count,
			bar_color, bar_width, bar_antialiased
		)
		if start_overlap == EndOverlap.ABOVE and start_enabled: # start outline when above
			draw_circle(
				start_center,
				start_radius * 2,
				start_outline_color,
				false, start_outline_width * 2, start_antialiased
			)
		if start_overlap != EndOverlap.BELOW and start_enabled: # start when not below
			draw_circle(
				start_center,
				start_radius * 2,
				start_color,
				true, -1, start_antialiased
			)
		if end_overlap == EndOverlap.ABOVE and end_enabled: # end outline when above
			draw_circle(
				end_center,
				end_radius * 2,
				end_outline_color,
				false, end_outline_width * 2, end_antialiased
			)
		if end_overlap != EndOverlap.BELOW and end_enabled: # end when not below
			draw_circle(
				end_center,
				end_radius * 2,
				end_color,
				true, -1, end_antialiased
			)
