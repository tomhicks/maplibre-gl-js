uniform lowp float u_device_pixel_ratio;
uniform sampler2D u_image;

in vec2 v_width2;
in vec2 v_normal;
in float v_gamma_scale;
in highp vec2 v_uv;
#ifdef GLOBE
in float v_depth;
#endif

#pragma mapbox: define lowp float blur
#pragma mapbox: define lowp float opacity

void main() {
    #pragma mapbox: initialize lowp float blur
    #pragma mapbox: initialize lowp float opacity

    // Calculate the distance of the pixel from the line in pixels.
    float dist = length(v_normal) * v_width2.s;

    // Calculate the antialiasing fade factor. This is either when fading in
    // the line in case of an offset line (v_width2.t) or when fading out
    // (v_width2.s)
    float blur2 = (blur + 1.0 / u_device_pixel_ratio) * v_gamma_scale;
    float alpha = clamp(min(dist - (v_width2.t - blur2), v_width2.s - dist) / blur2, 0.0, 1.0);

    // For gradient lines, v_lineprogress is the ratio along the
    // entire line, the gradient ramp is stored in a texture.
    vec4 color = texture(u_image, v_uv);

    fragColor = color * (alpha * opacity);

    #ifdef GLOBE
    if (v_depth > 1.0) {
        // See comment in line.fragment.glsl
        discard;
    }
    #endif

#ifdef OVERDRAW_INSPECTOR
    fragColor = vec4(1.0);
#endif
}
