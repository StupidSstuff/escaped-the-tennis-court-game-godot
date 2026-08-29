shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Godot already provides PI.

float hash(vec2 v)
{
    return fract(
        sin(dot(v, vec2(89.44, 19.36))) * 22189.22
    );
}

float i_hash(vec2 v, vec2 r)
{
    float h00 = hash(
        floor(v * r + vec2(0.0, 0.0)) / r
    );

    float h10 = hash(
        floor(v * r + vec2(1.0, 0.0)) / r
    );

    float h01 = hash(
        floor(v * r + vec2(0.0, 1.0)) / r
    );

    float h11 = hash(
        floor(v * r + vec2(1.0, 1.0)) / r
    );

    vec2 ip = smoothstep(
        vec2(0.0),
        vec2(1.0),
        mod(v * r, 1.0)
    );

    return mix(
        mix(h00, h10, ip.x),
        mix(h01, h11, ip.x),
        ip.y
    );
}

float noise(vec2 v)
{
    float sum = 0.0;

    for (int i = 1; i < 9; i++)
    {
        float fi = float(i);

        sum += i_hash(
            v + vec2(fi),
            vec2(2.0 * pow(2.0, fi))
        ) / pow(2.0, fi);
    }

    return sum;
}

// ------------------------------------------------------------
// Screen texture
// ------------------------------------------------------------

vec3 tex2D(vec2 uv)
{
    // Same behavior as the original shader.
    if (abs(uv.x - 0.5) > 0.5)
        return vec3(0.1);

    return texture(screen_texture, uv).rgb;
}

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

void fragment()
{
    vec2 resolution = VIEWPORT_SIZE;
    float time = TIME;

    // Equivalent to:
    // gl_FragCoord.xy / resolution
    vec2 uv = SCREEN_UV;
    vec2 uvn = uv;

    vec3 col = vec3(0.0);

    // --------------------------------------------------------
    // Tape wave
    // --------------------------------------------------------

    uvn.x += (
        noise(vec2(uvn.y, time)) - 0.5
    ) * 0.005;

    uvn.x += (
        noise(vec2(uvn.y * 100.0, time * 10.0)) - 0.5
    ) * 0.01;

    // --------------------------------------------------------
    // Tape crease
    // --------------------------------------------------------

    float tc_phase = clamp(
        (
            sin(
                uvn.y * 8.0 -
                time * PI * 1.2
            ) - 0.92
        )
        * noise(vec2(time)),
        0.0,
        0.01
    ) * 10.0;

    float tc_noise = max(
        noise(
            vec2(
                uvn.y * 100.0,
                time * 10.0
            )
        ) - 0.5,
        0.0
    );

    uvn.x -= tc_noise * tc_phase;

    // --------------------------------------------------------
    // Switching noise
    // --------------------------------------------------------

    float sn_phase = smoothstep(
        0.03,
        0.0,
        uvn.y
    );

    uvn.y += sn_phase * 0.3;

    uvn.x += sn_phase * (
        (
            noise(
                vec2(
                    uv.y * 100.0,
                    time * 10.0
                )
            ) - 0.5
        ) * 0.2
    );

    // --------------------------------------------------------
    // Main image
    // --------------------------------------------------------

    col = tex2D(uvn);

    col *= 1.0 - tc_phase;

    col = mix(
        col,
        col.yzx,
        sn_phase
    );

    // --------------------------------------------------------
    // Bloom / RGB bleed
    // --------------------------------------------------------

    for (int i = -4; i < 3; i++)
    {
        float x = float(i);

        col.r += tex2D(
            uvn + vec2(x, 0.0) * 0.007
        ).r * 0.1;

        col.g += tex2D(
            uvn + vec2(x - 2.0, 0.0) * 0.007
        ).g * 0.1;

        col.b += tex2D(
            uvn + vec2(x - 4.0, 0.0) * 0.007
        ).b * 0.1;
    }

    col *= 0.6;

    // --------------------------------------------------------
    // AC beat / brightness fluctuation
    // --------------------------------------------------------

    col *= 1.0 + clamp(
        noise(
            vec2(
                0.0,
                uv.y + time * 0.2
            )
        ) * 0.6 - 0.25,
        0.0,
        0.1
    );

    ALBEDO = col;
    ROUGHNESS = 1.0;
}