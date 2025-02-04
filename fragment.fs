#version 330 core
layout (location = 0) out vec4 fragColor;


#define PI 3.14159265
#define TAU (2*PI)
#define PHI (sqrt(5)*0.5 + 0.5)
#define saturate(x) clamp(x, 0, 1)


uniform vec2 u_resolution;

uniform float u_rotateX;
uniform float u_rotateY;
uniform float u_zoom;

uniform vec3 u_RayOrigin;

uniform float u_ConstA;
uniform float u_ConstB;
uniform float u_ConstC;
uniform float u_ConstD;
uniform float u_ConstE;

uniform float u_X;
uniform float u_Y;
uniform float u_Z;

uniform float u_Iterations;
uniform float u_Epsilon;

uniform int u_FracType;


const float FOV = 1.0;
const int MAX_STEPS = 512;
const float MAX_DIST = 1000;
float EPSILON = u_Epsilon; 
   
vec4 Union(vec4 obj1, vec4 obj2)
{
    return (obj1.x > obj2.x) ? obj2 : obj1;
}

vec2 Intersection(vec2 obj1, vec2 obj2)
{
    return (obj1.x > obj2.x) ? obj1 : obj2;
}

vec4 Difference(vec4 obj1, vec4 obj2)
{
    return (obj1.x > -obj2.x) ? obj1 : vec4(-obj2.x, obj2.yzw);
}

vec4 FSphere(vec3 Ray, float dist)
{
    float c = 4;
    Ray = mod(Ray + 0.5 * c, c) - c * 0.5;
    return vec4(length(Ray) - 1, vec3(1));
}

vec4 FBox(vec3 Ray, vec3 Sizes)
{
    vec3 q = abs(Ray) - Sizes;
    return vec4(length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0), vec3(1));
}

float FPlane (vec3 Ray, vec3 n, float h)
{
    return dot(Ray, n) + h;
}

vec4 FCubicMandelbulb(vec3 Ray)
{
    vec3 w = Ray;
    float m = dot(w,w); 
    return vec4(Ray, 1); 
}

// vec4 FMandelbulb(vec3 Ray)
// {
//     vec3 w = Ray;
//     float m = dot(w,w);

//     // vec4 trap = vec4(abs(w),m);
// 	float dz = 1.0;
    
// 	for(int i = 0; i < u_Iterations; i++)
//     {
//         if( m > 2)
//             break;
//         dz = 8.0*pow(m,3.5)*dz + 1.0;
      
//         // z = z^8+z
//         float r = length(w);
//         float b = 8.0*acos( w.y/r);
//         float a = 8.0*atan( w.x, w.z );
//         w = Ray + pow(r,8.0) * vec3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );      
        
//         // trap = min( trap, vec4(abs(w),m) );

//         m = dot(w,w);

//     }
//     return vec4(0.25*log(m)*sqrt(m)/dz, vec3(1));
// }

vec4 FMandelbulb(vec3 Ray)
{

    float Power = u_ConstA;
    vec3 z = Ray;
    float dr = 1.0;
    float r = length(z);
    //vec4 trap = vec4(abs(z),dot(z, z));
    r = length(z);
    for(int i = 0; i < u_Iterations ; ++i)
    {
        r = length(z);
            if (r > 2) break;

        float zr = pow(r, Power);
        float theta = Power * acos(z.y / r);
        float phi = Power * atan(z.x/ z.z);

        dr = pow(r, (Power - 1.0)) * Power * dr + 1.0;

        //trap = min( trap, vec4(abs(z),dot(z, z)));
        vec3 temp = vec3(u_X, u_Y, u_Z);
        temp == vec3(0.0) ? temp = Ray : temp;

        z = zr * vec3( sin(theta)*sin(phi), cos(theta), sin(theta)*cos(phi) ) + temp;
    }
    return vec4(0.5*log(r)*r/dr, vec3(1.0));
}

// vec4 FMandelbrotSet(vec3 Ray)
// {   

//     float Power = 2;
//     vec3 m = Ray;
//     float dr = 1.0;
//     float r = length(m);
//     for (int i = 0; i < u_Iterations; ++i)
//     {
//         float x = m.x, y = m.y, z = m.z;
//         float hyp_xy_sq = x * x + y * y;
//         float hyp_xy = sqrt(hyp_xy_sq);
//         r = sqrt(hyp_xy_sq + z * z);
//         dr = pow(r, Power - 1) * Power * dr + 1.0;
//         float theta = Power * acos(x/hyp_xy) * sign(y);
//         float phi = Power * asin(z/r);

//         r = pow(r, Power);
//         m = Ray + r * vec3(cos(theta)*cos(phi), sin(theta)*cos(phi), sin(phi));
        
//     }

    
//     return vec4(0.5*log(r)*r/dr, vec3(1));
// }


vec4 qSquare(vec4 q)
{
    return vec4(q.x*q.x - dot(q.zyw, q.zyw), 2 * q.x * q.yzw);
}
vec4 qCube(vec4 q)
{
    return q * (4 * q.x * q.x - dot(q, q) * vec4(3.0, 1.0, 1.0, 1.0));
}
float qLength2(vec4 q)
{
    return dot(q, q);
}
vec4 FJuliaSet(vec3 p)
{
    vec4 z = vec4 (p , 0.0) ;
    float dz2 = 1.0;
    float m2 = 0.0;
    vec4 Constant = vec4(u_X, u_Y, u_Z, u_ConstA);
    for ( int i = 0; i < u_Iterations; i ++)
    {
        dz2 *= 9.0 * qLength2(qSquare(z));
        z = qCube(z) + Constant;
        m2 = qLength2(z);
        if ( m2 > 256.0) break;

    }
    float d = 0.25 * log ( m2 ) * sqrt ( m2 / dz2 ) ;
    return vec4(d , vec3(1));
}

float minRadius2 = u_ConstD; // -1
float fixedRadius2 = u_ConstC; // 1
void sphereFold(inout vec3 z, inout float dz) {
	float r2 = dot(z,z);
	if (r2<minRadius2) { 
		// linear inner scaling
		float temp = (fixedRadius2/minRadius2);
		z *= temp;
		dz*= temp;
	} else if (r2<fixedRadius2) { 
		// this is the actual sphere inversion
		float temp =(fixedRadius2/r2);
		z *= temp;
		dz*= temp;
	}
}
float foldingLimit = u_ConstB; //1
void boxFold(inout vec3 z, inout float dz) {
	z = clamp(z, -foldingLimit, foldingLimit) * 2.0 - z;
}

vec4 FMandelbox(vec3 Ray)
{
    float Scale = u_ConstA;
    
    vec3 offset = Ray;



	float dr = 1.0;
	for (int n = 0; n < u_Iterations; n++) {
		boxFold(Ray,dr);       // Reflect
		sphereFold(Ray,dr);    // Sphere Inversion
 		
        Ray=Scale*Ray + offset;  // Scale & Translate

        dr = dr*abs(Scale)+1.0;
	}
	float r = length(Ray);
	return vec4(r/abs(dr), vec3(1)) ;
}

vec4 FSerpinskyTetrahidron(vec3 Ray)
{
    float Offset = 2 + u_zoom;
    float Scale = u_ConstA;
    int i;
    for (i = 0; i < u_Iterations; ++i)
    {
        if (Ray.x + Ray.y < 0)
            Ray.xy = -Ray.yx;
        if (Ray.x + Ray.z < 0)
            Ray.xz = -Ray.zx;
        if (Ray.y + Ray.z < 0)
            Ray.zy = -Ray.yz;
        Ray = Ray * Scale - Offset*(Scale - 1);
    }
    return vec4(length(Ray) * pow(Scale, - float(i)), vec3(1)) ;
}

vec4 map(vec3 Ray)
{
    vec4 res;
    //Ray.y -= 1;
    //vec4 Obj = FBox(Ray, vec3(1));
    //Ray.y += 1;
    // float sphereDist = FSphere(Ray, 1.0);
    // vec2 sphere = vec2(sphereDist, 2.0);
    switch (u_FracType)
    {
        case 1:
            res = FMandelbulb(Ray / (1 + u_zoom)) * (1 + u_zoom);
            break;
        case 2:
            res = FMandelbox(Ray / (1 + u_zoom)) * (1 + u_zoom);
            break;
        case 3:
            res = FJuliaSet(Ray / (1 + u_zoom)) * (1 + u_zoom);
            break;
        case 4:
            res = FSerpinskyTetrahidron(Ray);
            break;
        default:
            res = FBox(Ray, vec3(1));
    }


    //* (100 + u_zoom)

    return res;
}

vec4 RayMarching(vec3 RayOrigin, vec3 RayDirection)
{
    vec4 hit, object;
    for (int i = 0; i < MAX_STEPS; i++)
    {
        vec3 Ray = RayOrigin + object.x * RayDirection;
        hit = map(Ray);
        object.x += hit.x;
        object.yzw = hit.yzw;
        if ((abs(hit.x) < EPSILON) || (object.x > MAX_DIST)) break;
    }
    return object;
}

vec3 GetNormal(vec3 Plain)
{
    vec2 M0 = vec2(EPSILON, 0.0);
    // vec3 N = vec3(
    //     map(vec3(Plain.x + EPSILON, Plain.y, Plain.z)).x - map(vec3(Plain.x - EPSILON, Plain.y, Plain.z)).x,
    //     map(vec3(Plain.x, Plain.y + EPSILON, Plain.z)).x - map(vec3(Plain.x, Plain.y - EPSILON, Plain.z)).x,
    //     map(vec3(Plain.x, Plain.y, Plain.z  + EPSILON)).x - map(vec3(Plain.x, Plain.y, Plain.z - EPSILON)).x
    // );
    
    
    vec3 N = vec3(map(Plain).x) - vec3(map(Plain - M0.xyy).x, map(Plain - M0.yxy).x, map(Plain - M0.yyx).x);
    return normalize(N);
}

vec3 GetLight(vec3 Ray, vec3 RayDirection, vec3 color)
{
    vec3 LightPos = vec3(-20.0, -40.0, 30.0);
    vec3 L = normalize(RayDirection - LightPos);
    vec3 N = GetNormal(Ray);

    vec3 diffuse = color * clamp(dot(L, N), 0.0, 1.0);

    //float d = RayMarching(Ray + N * 0.02, normalize(LightPos)).x;
    // if (d < length(LightPos - Ray))
    //     return vec3(0);

    return diffuse;
}

mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

vec3 render (in vec2 uv) 
{
    vec3 Color;
    vec3 RayOrigin = u_RayOrigin;
    vec3 RayDirection = normalize(vec3(uv, FOV));
    RayDirection *= rotateX(u_rotateY) * rotateY(u_rotateX); 
    
    
    vec4 object = RayMarching(RayOrigin, RayDirection);
    
    if (object.x < MAX_DIST)
    {
        vec3 Ray = RayOrigin + object.x * RayDirection;
        Color += GetLight(Ray, RayDirection, object.yzw);
    }
    return Color;
}

vec2 GetUV(vec2 offset)
{
    return (2.0 * (gl_FragCoord.xy + offset) - u_resolution.xy) / u_resolution.y;
}

vec3 renderAAx4()
{
    vec4 EPSILON = vec4(0.125, -0.125, 0.375, -0.375);
    vec3 colAA = render(GetUV(EPSILON.xz)) + render(GetUV(EPSILON.yw)) + render(GetUV(EPSILON.wx)) + render(GetUV(EPSILON.zy));
    return colAA / 4.0;

}

void main()
{
    
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 Color = render(uv);


    fragColor = vec4(Color, 1.0);
}