shader_type canvas_item;

// made by _michdev https://github.com/mich-gamedev

// how fast it changes
uniform float speed = 1;
// how strong it moves, on each axis
uniform vec2 strength = vec2(4);
// how much difference there will be based on the vertex
uniform float vertex_strength = 1;
// how many seconds between each "jitter", if 0 it'll constantly move
uniform float jitter_amount: hint_range(0.0, 1000.0, 0.01) = 0.0;

void vertex() {
	float mod_time = jitter_amount > 0.0 ? (TIME - mod(TIME, jitter_amount)) : TIME;
	VERTEX += vec2(cos(mod_time * speed + VERTEX.x * vertex_strength), sin(mod_time * speed + VERTEX.y * vertex_strength)) * strength;
}