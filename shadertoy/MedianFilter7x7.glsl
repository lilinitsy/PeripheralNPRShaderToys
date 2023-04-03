#define WINDOW_SIZE 7
#define NUM_ELEMS WINDOW_SIZE * WINDOW_SIZE

void mainImage(out vec4 fragcolour, in vec2 fragcoord)
{
	vec3 values[NUM_ELEMS];
	vec2 pixel_size = 1.0 / iResolution.xy;
	vec2 uv = fragcoord / iResolution.xy;
	vec3 luminance_vals = vec3(0.2126, 0.7152, 0.0722);

	int filter_extent = WINDOW_SIZE / 2;
	int index = 0;

	// Gather input values
	for (int x = -filter_extent; x <= filter_extent; x++)
	{
		for (int y = -filter_extent; y <= filter_extent; y++)
		{
			vec2 offset = vec2(float(x), float(y)) * pixel_size;
			values[index] = texture(iChannel0, uv + offset).rgb;
			index++;
		}
	}

	// This may not work for size < 5
	for(int i = 1; i < NUM_ELEMS; i++)
	{
		vec3 key = values[i];
		int j = i - 1;
		while(j >= 0 && dot(values[j], luminance_vals) > dot(key, luminance_vals))
		{
			values[j + 1] = values[j];
			j--;
		}
		values[j + 1] = key;
	}

	// Return the median value
	fragcolour = vec4(values[(NUM_ELEMS - 1) / 2], 1.0);
}