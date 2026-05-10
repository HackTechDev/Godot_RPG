shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_linear;

// Paramètres du cône — mis à jour chaque frame depuis player.gd
uniform vec2  viewport_size      = vec2(1280.0, 720.0);
uniform vec2  player_screen_pos  = vec2(640.0, 360.0);
uniform float look_angle_rad     = 0.0;          // direction du regard en radians
uniform float cone_length_px     = 130.0;        // longueur du cône en pixels écran
uniform float cone_fov_half_rad  = 0.7854;       // demi-angle (45°)

// Paramètres visuels
uniform float noise_strength : hint_range(0.0, 0.5) = 0.13;
uniform float time_seed      : hint_range(0.0, 10000.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv        = SCREEN_UV;
	vec4 s         = texture(SCREEN_TEXTURE, uv);
	vec2 pixel_pos = uv * viewport_size;

	// Vecteur du joueur vers le pixel courant (espace écran)
	vec2  to_pixel   = pixel_pos - player_screen_pos;
	float dist       = length(to_pixel);

	// Différence angulaire normalisée dans [-PI, PI]
	float angle_px   = atan(to_pixel.y, to_pixel.x);
	float diff       = mod(angle_px - look_angle_rad + PI, 2.0 * PI) - PI;

	// Fondu doux sur les bords radial et angulaire du cône
	float radial_fade  = 1.0 - smoothstep(cone_length_px * 0.88, cone_length_px, dist);
	float angular_fade = 1.0 - smoothstep(cone_fov_half_rad * 0.88, cone_fov_half_rad, abs(diff));
	float factor       = radial_fade * angular_fade;

	if (factor > 0.0) {
		// Grayscale + grain
		float g     = dot(s.rgb, vec3(0.299, 0.587, 0.114));
		float grain = hash(pixel_pos + vec2(time_seed * 17.37, time_seed * 31.11));
		g = clamp(g + (grain - 0.5) * noise_strength, 0.0, 1.0);

		// Teinte verte NVG + légères scanlines
		vec3 nvg  = vec3(g * 0.08, g * 1.0, g * 0.10);
		nvg      *= 1.0 + sin(uv.y * 720.0 * PI) * 0.025;
		nvg       = clamp(nvg, 0.0, 1.0);

		COLOR = vec4(mix(s.rgb, nvg, factor), 1.0);
	} else {
		COLOR = s;
	}
}
