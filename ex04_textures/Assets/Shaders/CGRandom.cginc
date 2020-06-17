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
    float3 u = t * t * t * (10.0 - 15.0 * t + 6.0 * t * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);
    float x3 = lerp(v[4], v[5], u.x);
    float x4 = lerp(v[6], v[7], u.x);

    // Interpolate in the y direction
    float y1 = lerp(x1, x2, u.y);
    float y2 = lerp(x3, x4, u.y);
    
    // Interpolate in the z direction and return
    return lerp(y1, y2, u.z);
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
    float3 upLeftFront = float3(floor(c.x), ceil(c.y), floor(c.z));
    float3 upLeftBack = float3(floor(c.x), ceil(c.y), ceil(c.z));
    float3 downLeftFront = float3(floor(c.x), floor(c.y), floor(c.z));
    float3 downLeftBack = float3(floor(c.x), floor(c.y), ceil(c.z));
    float3 upRightFront = float3(ceil(c.x), ceil(c.y), floor(c.z));
    float3 upRightBack = float3(ceil(c.x), ceil(c.y), ceil(c.z));
    float3 downRightFront = float3(ceil(c.x), floor(c.y), floor(c.z));
    float3 downRightBack = float3(ceil(c.x), floor(c.y), ceil(c.z));
    float3 randUpLeftFront = (random3(upLeftFront));
    float3 randUpLeftBack = (random3(upLeftBack));
    float3 randDownLeftFront = (random3(downLeftFront));
    float3 randDownLeftBack = (random3(downLeftBack));
    float3 randUpRightFront = (random3(upRightFront));
    float3 randUpRightBack = (random3(upRightBack));
    float3 randDownRightFront = (random3(downRightFront));
    float3 randDownRightBack = (random3(downRightBack));
    
    float3 disUpLeftFront = upLeftFront - c;
    float3 disUpLeftBack = upLeftBack - c;
    float3 disUpRightFront = upRightFront - c;
    float3 disUpRightBack = upRightBack - c;
    float3 disDownLeftFront = downLeftFront - c;
    float3 disDownLeftBack = downLeftBack - c;
    float3 disDownRightFront = downRightFront - c;
    float3 disDownRightBack = downRightBack - c;
    
    float3 dotUpLeftFront = dot(randUpLeftFront, disUpLeftFront);
    float3 dotUpLeftBack = dot(randUpLeftBack, disUpLeftBack);
    float3 dotUpRightFront = dot(randUpRightFront, disUpRightFront);
    float3 dotUpRightBack = dot(randUpRightBack, disUpRightBack);
    float3 dotDownLeftFront = dot(randDownLeftFront, disDownLeftFront);
    float3 dotDownLeftBack = dot(randDownLeftBack, disDownLeftBack);
    float3 dotDownRightFront = dot(randDownRightFront, disDownRightFront);
    float3 dotDownRightBack = dot(randDownRightBack, disDownRightBack);
    
    float3 v[8] = {dotDownLeftBack, dotDownRightBack, dotUpLeftBack, dotUpRightBack, dotDownLeftFront,dotDownRightFront,dotUpRightFront,
     dotUpLeftFront};
    float3 fracC = frac(c);
    float randC = triquinticInterpolation(v, fracC);
    return randC;
}


#endif // CG_RANDOM_INCLUDED
