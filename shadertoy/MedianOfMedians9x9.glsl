// MEDIAN of MEDIANS

#define WINDOWSIZE 9
#define NUM_ELEMS WINDOWSIZE * WINDOWSIZE
#define NUM_BINS NUM_ELEMS / 5


void mainImage(out vec4 fragcolour, in vec2 fragcoord)
{
    vec3 luminance_vals = vec3(0.2126, 0.7152, 0.0722);
    vec2 pixel_size = 1.0 / iResolution.xy;
    vec2 uv = fragcoord / iResolution.xy;
    vec3 values[NUM_ELEMS];
    vec3 medians[NUM_BINS];
    int filter_extent = WINDOWSIZE / 2;
    int index = 0;

    for(int x = -filter_extent; x <= filter_extent; x++)
    {
        for(int y = -filter_extent; y <= filter_extent; y++)
        {
            vec2 offset = vec2(float(x), float(y)) * pixel_size;
            values[index] = texture(iChannel1, uv + offset).rgb;
            index++;
        }
    }

    for(int i = 0; i < NUM_BINS; i++)
    {
        vec3 intermediary_values[5];
        for(int j = 0; j < 5; j++)
        {
            intermediary_values[j] = values[i * 5 + j];
        }

        for(int j = 1; j < 5; j++)
        {
            vec3 key = intermediary_values[j];
            int k = j - 1;
            while(k >= 0 && dot(intermediary_values[k], luminance_vals) > dot(key, luminance_vals))
            {
                intermediary_values[k + 1] = intermediary_values[k];
                k = k - 1;
            }

            intermediary_values[k + 1] = key;
        }
        medians[i] = intermediary_values[2];
    }

    for(int i = 1; i < NUM_BINS; i++)
    {
        vec3 key = medians[i];
        int j = i - 1;
        while(j >= 0 && dot(medians[j], luminance_vals) > dot(key, luminance_vals))
        {
            medians[j + 1] = medians[j];
            j = j - 1;
        }

        medians[j + 1] = key;
    }

    if(iMouse.w > 0.0)
    {
        fragcolour = texture(iChannel1, uv);
    }
    
    else
    {
        fragcolour = vec4(medians[4], 1.0);
    }
}