shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled;

uniform float line_thickness : hint_range(0.001, 0.02) = 0.005;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fill_color : source_color = vec4(0.8, 0.8, 0.8, 1.0); 
uniform float mountain_scale : hint_range(1.0, 50.0) = 20.0;
uniform float mountain_scale_2 : hint_range(0.0, 1.0) = 0.5;
uniform int num_peaks : hint_range(3, 20) = 8;
uniform float mountain_height : hint_range(0.0, 1.0) = 0.3;
uniform float seed : hint_range(0.0, 1000.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    
    // Generate mountain peaks using straight line segments
    float mountain_y = 0.0;
    float segment_width = 1.0 / float(num_peaks);
    
    // Find which segment we're in
    int segment = int(uv.x / segment_width);
    float local_x = mod(uv.x, segment_width) / segment_width;
    
    // Generate heights for current and next segment with seed offset
    float height1 = sin((float(segment) + seed) * mountain_scale) * mountain_height * mountain_scale_2 + mountain_height;
    float height2 = sin((float((segment + 1) % num_peaks) + seed) * mountain_scale) * mountain_height * mountain_scale_2 + mountain_height;
    
    // Linear interpolation between segment heights
    mountain_y = mix(height1, height2, local_x);
    
    vec3 color = line_color.rgb;
    float alpha = 1.0; // Always opaque for proper depth testing
    
    // Fill everything below the mountain line
    if (uv.y > mountain_y) {
        float distance_to_line = abs(uv.y - mountain_y);
        float line_alpha = 1.0 - smoothstep(0.0, line_thickness, distance_to_line);
        
        if (line_alpha > 0.5) {
            color = line_color.rgb;
        } else {
            color = fill_color.rgb;
        }
    } else {
        // For areas above the mountain, you could either:
        // Option 1: Discard the fragment (won't write to depth buffer)
        discard;
        
        // Option 2: Use a transparent background color but keep alpha = 1.0
        // color = vec3(0.0, 0.0, 0.0);
        // alpha = 0.0; // Only if you want transparency above mountains
    }
    
    ALBEDO = color;
    ALPHA = alpha;
}