#define WINDOWSIZE 9 // Size of the local window
#define BIN_SIZE 3 // Size of each bin
#define NUM_BINS ((WINDOWSIZE / BIN_SIZE) * (WINDOWSIZE / BIN_SIZE))

#define values(i, j) texture(iChannel0, uv + ((vec2(i, j) - vec2(filter_extent)) * pixel_size)).rgb

void mainImage(out vec4 fragcolour, in vec2 fragcoord)
{
    vec3 luminance_vals = vec3(0.2126, 0.7152, 0.0722);
    vec2 pixel_size = 1.0 / iResolution.xy;
    vec2 uv = fragcoord / iResolution.xy;
    vec3 medians[NUM_BINS];
    int filter_extent = WINDOWSIZE / 2;

    for(int i = 0; i < NUM_BINS; i++)
    {
        vec3 intermediary_values[BIN_SIZE * BIN_SIZE];
        int bin_row = i / (WINDOWSIZE / BIN_SIZE);
        int bin_col = i % (WINDOWSIZE / BIN_SIZE);
        
        for(int r = 0; r < BIN_SIZE; r++)
        {
            for(int c = 0; c < BIN_SIZE; c++)
            {
                vec3 value = values(bin_col * BIN_SIZE + c, bin_row * BIN_SIZE + r);
                intermediary_values[r * BIN_SIZE + c] = value;
            }
        }

        // Sort intermediary_values using an insertion sort to find the median.
        for(int j = 1; j < BIN_SIZE * BIN_SIZE; j++)
        {
            vec3 key = intermediary_values[j];
            int k = j - 1;
            while (k >= 0 && dot(intermediary_values[k], luminance_vals) > dot(key, luminance_vals))
            {
                intermediary_values[k + 1] = intermediary_values[k];
                k = k - 1;
            }
            intermediary_values[k + 1] = key;
        }
        medians[i] = intermediary_values[BIN_SIZE * BIN_SIZE / 2];
    }

    // Sort the medians array to find the overall median.
    for (int i = 1; i < NUM_BINS; i++)
    {
        vec3 key = medians[i];
        int j = i - 1;
        while (j >= 0 && dot(medians[j], luminance_vals) > dot(key, luminance_vals))
        {
            medians[j + 1] = medians[j];
            j = j - 1;
        }
        medians[j + 1] = key;
    }

    // Output the median color.
    if(iMouse.w > 0.0)
    {
        fragcolour = texture(iChannel0, uv);
    }
    
    else
    {
        fragcolour = vec4(medians[NUM_BINS / 2], 1.0);
    }
}