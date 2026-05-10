shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_linear;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.13;
uniform float vignette_power : hint_range(0.0, 3.0) = 1.4;
uniform float time_seed : hint_range(0.0, 10000.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 s = texture(SCREEN_TEXTURE, uv);

	// Grayscale luminance
	float g = dot(s.rgb, vec3(0.299, 0.587, 0.114));

	// Grain : bruit aléatoire indépendant par pixel et par frame
	float grain = hash(uv * vec2(1280.0, 720.0) + vec2(time_seed * 17.37, time_seed * 31.11));
	g = clamp(g + (grain - 0.5) * noise_strength, 0.0, 1.0);

	// Teinte verte NVG
	vec3 nvg = vec3(g * 0.08, g * 1.0, g * 0.10);

	// Vignette radiale
	vec2 centered = uv - 0.5;
	float dist = length(centered);
	float vig = smoothstep(0.7, 0.2, dist * vignette_power);
	nvg *= vig;

	// Légères lignes de balayage (scanlines)
	float scan = 1.0 + sin(uv.y * 720.0 * PI) * 0.025;
	nvg *= scan;

	COLOR = vec4(clamp(nvg, 0.0, 1.0), 1.0);
}
