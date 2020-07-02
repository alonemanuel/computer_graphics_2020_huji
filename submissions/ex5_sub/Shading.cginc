// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    // Your implementation
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 h = normalize(l + v);
    float3 specular = pow(max(0, dot(n, h)), shininess) * 0.4;
    return diffuse + specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    // Your implementation
    float3 v = -ray.direction;
    float3 n = hit.normal;
    float3 r = (2.0 * dot(v, n) * n) - v;
    
    ray.direction = r;
    ray.origin = hit.position + EPS*n; 

    ray.energy = ray.energy * hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float eta;
    float3 n = hit.normal;
    float3 i = ray.direction;
    float entryDirection = dot(hit.normal, i);
    if ( entryDirection <= 0)
    {
        eta = 1 / hit.material.refractiveIndex;
    }
    else
    {
        eta = hit.material.refractiveIndex;
        n = -1 * n;
    }
    float c1 = abs(entryDirection); 
    float temp = 1- pow(c1, 2);
    float c2 = sqrt(1-pow(eta, 2) *  temp);
        
    ray.direction = normalize( eta * i + (eta * c1 - c2) * n); 
        
    ray.origin = hit.position - (EPS * n);
        
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}