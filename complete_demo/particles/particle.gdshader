shader_type spatial;
render_mode shadows_disabled, unshaded, skip_vertex_transform;

void vertex() {
	mat3 small_model_matrix = mat3(MODEL_MATRIX);

	small_model_matrix *= inverse(mat3(VIEW_MATRIX)) * small_model_matrix;

	mat4 final_model_matrix = mat4(
		vec4(small_model_matrix[0], 0),
		vec4(small_model_matrix[1], 0),
		vec4(small_model_matrix[2], 0),
		MODEL_MATRIX[3]
	);

	VERTEX = (VIEW_MATRIX * final_model_matrix * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if((UV.x - 0.5) * (UV.x - 0.5) + (UV.y - 0.5) * (UV.y - 0.5) > 0.25)
	{
		discard;
	}

	ALBEDO = COLOR.xyz;
}
