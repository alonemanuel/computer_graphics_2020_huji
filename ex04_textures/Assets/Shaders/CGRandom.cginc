#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float2 values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float2 values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float2 v[4], float2 t)
{
    // Your implementation
    float2 u = t * t * t * (10.0 - 15.0 * t + 6.0 * t * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float3 values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float3 v[8], float3 t)
{
    // Your implementation
    return 0;
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float2 upLeft = float2(floor(c.x), ceil(c.y));
    float2 downLeft = float2(floor(c.x), floor(c.y));
    float2 upRight = float2(ceil(c.x), ceil(c.y));
    float2 downRight = float2(ceil(c.x), floor(c.y));
    float2 randUpLeft = (random2(upLeft));
    float2 randDownLeft = (random2(downLeft));
    float2 randUpRight = (random2(upRight));
    float2 randDownRight = (random2(downRight));
    
    float2 v[4] = { randDownLeft, randDownRight, randUpLeft, randUpRight};
    float2 fracC = frac(c);
    float randC = bicubicInterpolation(v, fracC);
    // Your implementation
    return randC;
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{
    // Your implementation
    float2 upLeft = float2(floor(c.x), ceil(c.y));
    float2 downLeft = float2(floor(c.x), floor(c.y));
    float2 upRight = float2(ceil(c.x), ceil(c.y));
    float2 downRight = float2(ceil(c.x), floor(c.y));
    float2 randUpLeft = (random2(upLeft));
    float2 randDownLeft = (random2(downLeft));
    float2 randUpRight = (random2(upRight));
    float2 randDownRight = (random2(downRight));
    
    float2 disUpLeft = upLeft - c;
    float2 disUpRight = upRight - c;
    float2 disDownLeft = downLeft - c;
    float2 disDownRight = downRight - c;
    
    float2 dotUpLeft = dot(randUpLeft, disUpLeft);
    float2 dotUpRight = dot( randUpRight, disUpRight);
    float2 dotDownLeft = dot( randDownLeft, disDownLeft);
    float2 dotDownRight = dot( randDownRight, disDownRight);
    
    float2 v[4] = { dotDownLeft, dotDownRight, dotUpLeft, dotUpRight};
    float2 fracC = frac(c);
    float randC = biquinticInterpolation(v, fracC);
    return randC;
}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    // Your implementation
    return 0;
}


#endif // CG_RANDOM_INCLUDED
