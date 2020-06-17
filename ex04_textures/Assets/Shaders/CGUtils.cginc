#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    // Your implementation
    float r = length(pos);
    float th = atan2(pos.z, pos.x);
    float ph = acos(pos.y / r);
    
    float2 uv;
    uv.x = 0.5 + (th/(2*PI));
    uv.y = 1 - (ph/PI);
    return uv;
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    // Your implementation
    float3 ambient = ambientIntensity*albedo;
    float3 diffuse = max(0,dot(n,l))*albedo;
    float3 h = normalize((l+v)/2);
    float3 specular =pow( max(0,dot(n,h)),shininess)*specularity;

    return ambient + diffuse + specular;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    // Your implementation
    
    float f_du = ((tex2D(i.heightMap, i.uv + i.du)) - (tex2D(i.heightMap, i.uv))) / i.du; 
    float f_dv = ((tex2D(i.heightMap, i.uv + i.dv)) - (tex2D(i.heightMap, i.uv))) / i.dv; 
    float3 n_h = normalize(float3((-1  * i.bumpScale * f_du), (-1 * i.bumpScale * f_dv), 1));
    
    float3 n_world = normalize(mul(unity_ObjectToWorld, i.normal));
    float3 t_world = mul(unity_ObjectToWorld, i.tangent);
    float3 b = cross(t_world, n_world);
    
    float3 world_nh = n_h.x*t_world + n_h.y*b + n_h.z*n_world;
    return normalize(world_nh);
}


#endif // CG_UTILS_INCLUDED
