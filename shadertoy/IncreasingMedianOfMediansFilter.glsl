#define MAX_WINDOWSIZE 21
#define values(i, j) texture(iChannel0, uv + ((vec2(i, j) - vec2(filter_extent)) * pixel_size)).rgb
#define NUM_BINS ((MAX_WINDOWSIZE / BIN_SIZE) * (MAX_WINDOWSIZE / BIN_SIZE))
#define BIN_SIZE 3

void mainImage(out vec4 fragcolour, in vec2 fragcoord)
{
    vec3 luminance_vals = vec3(0.2126, 0.7152, 0.0722);
    vec2 pixel_size = 1.0 / iResolution.xy;
    vec2 uv = fragcoord / iResolution.xy;


    // Determine windowsize based on distance from center
    float dist_from_center = length(uv - vec2(0.5, 0.5));
    int WINDOWSIZE =  2 * int(float(MAX_WINDOWSIZE) * dist_from_center) + 1;  
    int filter_extent = WINDOWSIZE / 2;
    int bincount = WINDOWSIZE == MAX_WINDOWSIZE ? NUM_BINS : ((WINDOWSIZE / BIN_SIZE + 1) * (WINDOWSIZE / BIN_SIZE + 1));
    vec3 medians[NUM_BINS];

    for(int i = 0; i < bincount; i++)
    {
        vec3 intermediary_values[BIN_SIZE * BIN_SIZE];
        int bin_row = i / (WINDOWSIZE / BIN_SIZE);
        int bin_col = i % (WINDOWSIZE / BIN_SIZE);
        
        for(int r = 0; r < BIN_SIZE; r++)
        {
            for(int c = 0; c < BIN_SIZE; c++)
            {
                intermediary_values[r * BIN_SIZE + c] = values(bin_col * BIN_SIZE + c, bin_row * BIN_SIZE + r);
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
    for (int i = 1; i < bincount; i++)
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
        if(bincount == 0)
        {
            fragcolour = texture(iChannel0, uv);
        }
        
        else
        {
            fragcolour = vec4(medians[bincount / 2], 1.0);
        }
    }
}