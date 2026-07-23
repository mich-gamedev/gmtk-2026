shader_type canvas_item;

global uniform vec4 blue_filter;
global uniform vec4 blue_filter_2;
global uniform sampler2D blue_texture;
global uniform sampler2D blue_texture_2;
global uniform vec4 red_filter;
global uniform vec4 red_filter_2;
global uniform sampler2D red_texture;
global uniform sampler2D red_texture_2;
global uniform vec4 green_filter;
global uniform vec4 green_filter_2;
global uniform sampler2D green_texture;
global uniform sampler2D green_texture_2;

uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	vec4 new_color = screen;
	// red
	vec4 red_color = mix(red_filter, red_filter_2, texture(red_texture, mod(3. * (SCREEN_UV) + vec2(TIME * 2., sin(TIME * .6)), 1)) * texture(red_texture_2, mod((4. * (SCREEN_UV) + vec2(TIME * -4., cos(TIME) * 2.)), 1)));
	new_color = mix(new_color, red_color, screen.r);
	// green
	vec4 green_color = mix(green_filter, green_filter_2, texture(green_texture, mod(3. * (SCREEN_UV) + vec2(TIME * 2., sin(TIME * .6)), 1)) * texture(green_texture_2, mod((4. * (SCREEN_UV) + vec2(TIME * -4., cos(TIME) * 2.)), 1)));
	new_color = mix(new_color, green_color, screen.g);
	// blue
	vec4 blue_color = mix(blue_filter, blue_filter_2, texture(blue_texture, mod(3. * (SCREEN_UV) + vec2(TIME * 2., sin(TIME * .6)), 1)) * texture(blue_texture_2, mod((4. * (SCREEN_UV) + vec2(TIME * -4., cos(TIME) * 2.)), 1)));
	new_color = mix(new_color, blue_color, screen.b);
	COLOR = new_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
