shader_type spatial;
render_mode world_vertex_coords, cull_disabled;

varying float z_dist;
varying vec3 frag_normal;

uniform float max_dist = 50.0f;

uniform sampler2D noise_texture;
//uniform sampler2D trail_data;
uniform sampler2D trail_texture;
uniform vec2 trail_postion = vec2(0,0);
uniform float trail_scale = 0.5;
uniform float amplitude = 0.1;
uniform float frequency = 5.0;
uniform float time = 0.0;

uniform float first_wave_dir = 0.0;
uniform float second_wave_dir = 0.7;
uniform float gerstner_coef = 1.0;

uniform float ripple_depth = 0.5;
uniform float ripple_speed = 0.009;

uniform vec4 water_color: hint_color = vec4(0.1, 0.1, 0.9, 1.0);

vec2 first_dir_vect(){
	return vec2(cos(first_wave_dir), sin(first_wave_dir));
}

vec2 second_dir_vect(){
	return vec2(cos(second_wave_dir), sin(second_wave_dir));
}

float first_dir(vec2 pos){
	vec2 dir = first_dir_vect();
	return dir.x * pos.x + dir.y * pos.y;
}

float second_dir(vec2 pos){
	vec2 dir = second_dir_vect();
	return dir.x * pos.x + dir.y * pos.y;
}

float wave_height(vec2 pos){
	float first = first_dir(pos);
	float second = second_dir(pos);
	return amplitude * sin(first * frequency + time)
	+ amplitude * sin(second * frequency + time);
}

vec2 wave_gerstner(vec2 pos){
	float frst = cos(first_dir(pos) * frequency + time);
	float scnd = cos(second_dir(pos) * frequency + time);
	vec2 fdir = first_dir_vect();
	vec2 sdir = second_dir_vect();
	float x = fdir.x * frst + sdir.x * scnd;
	float y = fdir.y * frst + sdir.y * scnd;
	return gerstner_coef * amplitude * vec2(x,y);
}


void vertex() {
	float e = 0.02;
	vec3 vertex_offset_x = VERTEX + vec3(e,0,0);
	vec3 vertex_offset_z = VERTEX + vec3(0,0,e);
	vec3 vertex_pos = VERTEX;
	
	vec3 res_pos, res_offset_x, res_offset_z;
	res_pos.y = vertex_pos.y + wave_height(vertex_pos.xz);
	res_pos.xz = vertex_pos.xz + wave_gerstner(vertex_pos.xz);
	
	res_offset_x.y = vertex_offset_x.y + wave_height(vertex_offset_x.xz);
	res_offset_x.xz = vertex_offset_x.xz + wave_gerstner(vertex_offset_x.xz);
	
	res_offset_z.y = vertex_offset_z.y + wave_height(vertex_offset_z.xz);
	res_offset_z.xz = vertex_offset_z.xz + wave_gerstner(vertex_offset_z.xz);
	
	vec3 vect_x = res_offset_x - res_pos;
	vec3 vect_z = res_offset_z - res_pos;
	
//	float dent_dist = clamp(length(vec4(VERTEX, 1.0).xz) * 0.1, 0.0, 1.57);
//	res_pos.y -= cos(dent_dist) * 5.0;
	
	//vec4 VERTEX_WORLD = CAMERA_MATRIX * vec4(VERTEX, 1.0);
	vec2 uv = res_pos.xz * 0.01;
	vec4 t = texture(trail_texture, (uv + trail_postion / 100.0) * (1.0/trail_scale) 
		+ vec2(0.5,0.5)); // STRAMGE UV OFFSET BETWEEEN FRAGMENT AND VERTEX I CANT EXPLAIN

	VERTEX = res_pos + (vec3(0,t.g - t.b,0) * 0.5) + vec3(0,0.25,0);
	
	z_dist = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).z * -1.0;
	frag_normal = normalize(cross(vect_z,vect_x));
}

void fragment(){
	//ALPHA_SCISSOR = 0.5;
	//ALPHA = float(z_dist < max_dist);

	//float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
//	vec3 screen_tex_col = vec3(1.0,1.0,1.0); //textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb * 3.15;
//	depth = depth *2.0 -1.0;
//	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
//	depth = depth + VERTEX.z;
	//depth = clamp(exp(-depth*1.5), 0.0, 1.0);
	
	vec4 VERTEX_WORLD = CAMERA_MATRIX * vec4(VERTEX, 1.0);
	float height = clamp(VERTEX_WORLD.y * 0.5 - 0.2, 0.0, 1.0);
	vec3 color = water_color.xyz;
	
	vec2 uv = VERTEX_WORLD.xz * 0.01;
	
	vec4 n1 = texture(noise_texture, uv + vec2(time*ripple_speed));
	vec4 n2 = texture(noise_texture, -uv + vec2(time*ripple_speed));
	vec4 noise_normal = mix(n1,n2,0.5);
	
//	const int size = 16;
//	for(int i=0; i<size; ++i){
//		float x = (float(i)+0.5f)/float(size);
//		vec4 data = texture(trail_data, vec2(x, 0.5));
//		vec2 position = data.xy;
//		float strength = data.z;
//		if(length(VERTEX_WORLD.xz - position) < (strength+0.5))
//			color  = vec3(1.0, 1.0, 1.0);
//	}
	
	
	//color = vec3(0.0,0,0);
	vec4 ripple = texture(trail_texture, (uv + trail_postion / 100.0) * (1.0/trail_scale) 
		+ vec2(0.5,0.5));
	color += vec3(ripple.r);
	ALBEDO = color;
	if(ripple.b > 1.0) ALPHA = 0.0;
	
	EMISSION = vec3(height * 0.2 + ripple.r * 0.1);
	
	
	NORMALMAP = noise_normal.xyz;
	NORMALMAP_DEPTH = ripple_depth;
	
	mat3 invcam = mat3( INV_CAMERA_MATRIX[0].xyz,
					INV_CAMERA_MATRIX[1].xyz,
					INV_CAMERA_MATRIX[2].xyz);
	
	//NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	NORMAL = invcam * frag_normal;
	
	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = /*1.0;*/0.2;
	
	ALPHA_SCISSOR = 0.5;
}
