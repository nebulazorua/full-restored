//source: https://www.shadertoy.com/view/fsV3R3

#pragma header

float Pi = 6.28318530718; // Pi*2

// GAUSSIAN BLUR SETTINGS {{{
uniform float Directions = 8.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
uniform float Quality = 6.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
uniform float Size = 8.0; // BLUR SIZE (Radius)
// GAUSSIAN BLUR SETTINGS }}}
   

void main()
{

    vec2 Radius = Size/openfl_TextureSize.xy;
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = openfl_TextureCoordv;
    // Pixel colour

    vec4 sampleColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec4 Color = flixel_texture2D(bitmap, uv);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
			Color += flixel_texture2D( bitmap, uv+vec2(cos(d),sin(d))*Radius*i);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions + Directions;

    gl_FragColor = Color;

}