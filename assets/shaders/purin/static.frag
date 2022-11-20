#pragma header

vec2 iResolution = openfl_TextureSize;
uniform float iTime;

float Noise21 (vec2 p, float ta, float tb) {
    return fract(sin(p.x*ta+p.y*tb)*5678.);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;

    uv = floor(uv.xy * 128.);
    uv.xy += 0.1;
    float t = iTime+123.; // tweak the start moment
    float ta = t*.654321;
    float tb = t*(ta*.123456);
    
    float c = Noise21(uv, ta, tb);
    vec3 col = vec3(c);

    gl_FragColor = vec4(col,1.0) * openfl_Alphav;
}