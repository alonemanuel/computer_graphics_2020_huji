// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    // Your implementation
    float currBestHitDistance = 0;
    
    float3 c = sphere.xyz;      // sphere center
    float r = sphere.w;         // sphere radius
    
    float3 r_o = ray.origin;    // ray origin
    float3 r_d = ray.direction; // ray direction
    
    float A = 1;
    float B = 2 * dot((r_o - c), r_d);
    float C = dot((r_o - c), (r_o - c)) - r*r;
    
    float disc = B*B - 4*A*C;
    
    if (disc < 0) {
        currBestHitDistance = 1.#INF;
    }
    if (disc = 0) {
        currBestHitDistance = -B / 2*A;
    }
    if (disc > 0) {
        float t_0 = (-B + sqrt(disc)) / 2*A;
        float t_1 = (-B - sqrt(disc)) / 2*A;
        currBestHitDistance = min(t_0, t_1);
    }
    
    if (currBestHitDistance < bestHit.distance) {
        bestHit.material = material;
        bestHit.distance = currBestHitDistance;
        bestHit.position = r_o + (r_d * currBestHitDistance);
        bestHit.normal = normalize(bestHit.position - c);
    }
    
     
    
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    // Your implementation
    float currBestHitDistance = 0;
    
    float3 r_o = ray.origin;    // ray origin
    float3 r_d = ray.direction; // ray direction
    
    float r_d_dot_n = dot(r_d, n);
    if (r_d_dot_n != 0) {
        float mone = -dot((r_o - c), n);
        currBestHitDistance = mone / r_d_dot_n;    
    }
    else {
        currBestHitDistance = 1.#INF;
    }
    
    if (currBestHitDistance < bestHit.distance) {
        bestHit.material = material;
        bestHit.distance = currBestHitDistance;
        bestHit.position = r_o + (r_d * currBestHitDistance);
        bestHit.normal = n;
    }    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    // Your implementation
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    // Your implementation
}