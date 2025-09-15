shader_type spatial;
render_mode blend_mix, depth_draw_opaque;
uniform float line_thickness : hint_range(0.001, 0.02) = 0.005;
uniform vec4 line_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fill_color = vec4(0.8, 0.8, 0.8, 0.8); // Semi-transparent
uniform float mountain_scale : hint_range(1.0, 50.0) = 20.0;
uniform float mountain_scale_2 : hint_range(0.0,1.0) = 0.5;
uniform int num_peaks : hint_range(3, 20) = 8;
uniform float mountain_height : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec2 uv = UV;
    float alpha = 0.0;
    
    // Generate mountain peaks using straight line segments
    float mountain_y = 0.0;
    float segment_width = 1.0 / float(num_peaks);
    
    // Find which segment we're in
    int segment = int(uv.x / segment_width);
    float local_x = mod(uv.x, segment_width) / segment_width;
    
    // Generate heights for current and next segment
    float height1 = sin(float(segment) * mountain_scale) * mountain_height * mountain_scale_2 + mountain_height;
    float height2 = sin(float((segment + 1) % num_peaks) * mountain_scale) * mountain_height * mountain_scale_2 + mountain_height;
    
    // Linear interpolation between segment heights
    mountain_y = mix(height1, height2, local_x);
    
    vec3 color = line_color.rgb;
    
    // Fill everything below the mountain line
    if (uv.y > mountain_y) {
        float distance_to_line = abs(uv.y - mountain_y);
        float line_alpha = 1.0 - smoothstep(0.0, line_thickness, distance_to_line);
        
        if (line_alpha > 0.5) {
            color = line_color.rgb;
            alpha = line_color.a;
        } else {
            color = fill_color.rgb;
            alpha = fill_color.a;
        }
    }
    
    ALBEDO = color;
    ALPHA = alpha;
}