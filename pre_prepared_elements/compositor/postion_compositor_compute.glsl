#[compute]
#version 450

#define FLT_MAX 3.402823466e+38
#define FLT_MIN 1.175494351e-38

// A samplre to Godot's depth texture
layout(set = 0, binding = 0) uniform sampler2D depth_sampler;
// An output image we created for this
layout(rgba16f, set = 0, binding = 1) uniform writeonly image2D position_output;

// We define the struct to match Godot's scene data buffer (BOILERPLATE)
// ----------------------------------------------------------------------
struct SceneData {
	highp mat4 projection_matrix;
	highp mat4 inv_projection_matrix;
	highp mat3x4 inv_view_matrix;
	highp mat3x4 view_matrix;
};

layout(set = 0, binding = 2, std140) uniform SceneDataBlock {
	SceneData data;
}
scene;

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

mat4 mat3x4_to_mat4(highp mat3x4 value) {
	return transpose(mat4(
		value[0],
		value[1],
		value[2],
		vec4(0.0, 0.0, 0.0, 1.0)
	));
}

void main() 
{
	// Get the size of the depth sampler image, equivalent to render size
	ivec2 render_size = ivec2(textureSize(depth_sampler, 0));

	// Get the pixel we are in
	ivec2 uvi = ivec2(gl_GlobalInvocationID.xy);

	// If this pixel is outside the image, return
	if ((uvi.x >= render_size.x) || (uvi.y >= render_size.y)) 
	{
		return;
	}

	// Convert the pixel into a uv value between (0, 0) - (1, 1)
	vec2 uvn = vec2(uvi) / render_size;

	// Sample from the depth texture
	float depth = textureLod(depth_sampler, uvn, 0.0).x;
	
	// Get the updated scene data
	SceneData scene_data = scene.data;

	// This is a common function that you will see in shader materials as well to get the world position of a pixel
	// from the depth texture and view data.
	mat4 inv_view_matrix = mat3x4_to_mat4(scene_data.inv_view_matrix);

	vec4 world_position = inv_view_matrix * scene_data.inv_projection_matrix
	* vec4(uvn * 2.0 - 1.0, depth, 1.0);

	world_position.xyz /= world_position.w;

	// Feed the final position into our output position texture
	imageStore(position_output, uvi, vec4(world_position.xyz, 1.0));
}