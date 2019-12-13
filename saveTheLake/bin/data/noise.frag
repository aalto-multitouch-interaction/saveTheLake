
precision highp float;

uniform sampler2D tex0;

uniform vec2 iResolution;
uniform float iTime;

varying vec2 texCoordVarying;

float aspect = iResolution.x*1.0/iResolution.y;
float w = 50./sqrt(iResolution.x*aspect+iResolution.y);

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}
float tri(in float x){return abs(fract(x)-.5);}
vec2 tri2(in vec2 p){return vec2(tri(p.x+tri(p.y*2.)),tri(p.y+tri(p.x*2.)));}
mat2 m2 = mat2( 0.970,  0.242, -0.242,  0.970 );

//Animated triangle noise, cheap and pretty decent looking.
float triangleNoise()
{
    float speed = 0.5;
    
    vec2 p = gl_FragCoord.xy*1.0 / iResolution.xy*2.-1.;
    p = p / (w*w);
    float z=1.5;
    float z2=1.5;
    float rz = 0.;
    vec2 bp = p;
    for (float i=0.; i<=3.; i++ )
    {
        vec2 dg = tri2(bp*2.)*.8;
        dg *= mm2(iTime * speed);
        p += dg/z2;

        bp *= 1.6;
        z2 *= .6;
        z *= 1.8;
        p *= 1.2;
        p*= m2;
        
        rz+= (tri(p.x+tri(p.y)))/z;
    }
    
    return (rz * 0.9 + 0.4) - .66;
}

void main()
{
    float amount = 0.5;
    
    vec2 pixel = 1.0 / iResolution.xy;
    vec4 color = texture2D(tex0, texCoordVarying);
    vec4 color_b = texture2D(tex0, vec2(texCoordVarying.x, texCoordVarying.y + 10.*pixel.y));
    vec4 color_bb = texture2D(tex0, vec2(texCoordVarying.x, texCoordVarying.y + 20.*pixel.y));

    if((color.b > color.r) && (color.b > color.g) && (color.b > 0.8)) {
        if((color != color_b) && (color != color_bb)) {
            color /= 2.;
        } else {
            color = vec4(8., 87., 195., 255.) / 255.;
        }
        color += triangleNoise() * amount;
    }
    
    if(color.r + color.b + color.g > 2.8) {
        vec4 colorA = vec4(254.,245.,200.,255.) / 255.;
        vec4 colorB = vec4(235.,189.,120.,255.) / 255.;
        float pct = (1. - gl_FragCoord.x / iResolution.x);
        color = mix(colorA, colorB, pct);
        //color = vec4(250., 250., 250., 255.) / 255.;
    }
    
    if(color.r == 1.0) {
        float min_dist = 100.0;
        for(int i=-10; i<11; i++){
            for(int j=-10; j<11; j++){
                vec4 color_o = texture2D(tex0, vec2(texCoordVarying.x + float(i)*pixel.x, texCoordVarying.y + float(j)*pixel.y));
                if(color_o.r != 1.0) {
                    float dist = pow((pow(float(i),2.) + pow(float(j),2.)), 0.5);
                    if(dist<min_dist) min_dist = dist;
                }
            }
        }
        float pct = clamp(min_dist / pow(200.,0.5), 0.0, 1.0);
        vec4 colorA = vec4(128.,35.,36.,255.) / 255.;
        vec4 colorB = vec4(255.,0.,0.,255.) / 255.;
        color = mix(colorA, colorB, pct);
    }
    gl_FragColor = color;
}
