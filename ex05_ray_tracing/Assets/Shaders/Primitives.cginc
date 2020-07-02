// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    // Your implementation
    float currBestHitDistance = 1.#INF;
    
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
    else if (disc == 0) {
        currBestHitDistance = -B / (2*A);
    }
    else if (disc > 0) {
        float t_0 = (-B + sqrt(disc)) / (2*A);
        float t_1 = (-B - sqrt(disc)) / (2*A);
        
        if (t_0 < 0 && t_1 >= 0) {
            currBestHitDistance = t_1;
        }
        else if ( t_1 < 0 && t_0 >= 0) {
            currBestHitDistance = t_0;
        }
        else if ( t_1 >= 0 && t_0 >= 0) {        
            currBestHitDistance = min(t_0, t_1);
        }
    }
    
    if (currBestHitDistance>0 && currBestHitDistance < bestHit.distance) {
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
    float currBestHitDistance = 1.#INF;
    
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
    
    if (currBestHitDistance>0 && currBestHitDistance < bestHit.distance) {
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
    float currBestHitDistance = 1.#INF;
    
    float3 r_o = ray.origin;    // ray origin
    float3 r_d = ray.direction; // ray direction
    
    float r_d_dot_n = dot(r_d, n);
    if (r_d_dot_n != 0) {
        float mone = -dot((r_o - c), n);
        currBestHitDistance = mone / r_d_dot_n;    
    }
    else {
        currBestHitDistance = 1.#INF;
        return;
    }
    
    if (currBestHitDistance>0 && currBestHitDistance < bestHit.distance) {
        bestHit.position = r_o + (r_d * currBestHitDistance);
        float3 floor_pos = floor(bestHit.position * 2);
        float pos_sum;
        if ( n.x == 1)
        {
            pos_sum = floor_pos.y + floor_pos.z;   
        }
        if ( n.y == 1)
        {
            pos_sum = floor_pos.x + floor_pos.z; 
        }
        if (n.z == 1)
        {
            pos_sum = floor_pos.x + floor_pos.y; 
        }          
        if (pos_sum % 2.0 == 0.0) {
            bestHit.material = m1;
        }
        else {
            bestHit.material = m2;
        }
        bestHit.distance = currBestHitDistance;
        bestHit.normal = n;
    } 
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    // Your implementation
    float3 ac = a - c;
    float3 bc = b - c;
    float3 n_triangle = normalize(cross(ac, bc)); 
    float3 r_o = ray.origin;    // ray origin
    float3 r_d = ray.direction; // ray direction
    float r_d_dot_n = dot(r_d, n_triangle);
    float p_dist = 1.#INF;
    
    // check if point is on triangle plane 
    
    if (r_d_dot_n != 0) {
        float mone = -dot((r_o - c), n_triangle);
        p_dist = mone / r_d_dot_n;          
    }
    else {
       return; 
    }
    
    // assuming point is on plane, check if in triangle
    float3 p = r_o + (r_d * p_dist);
    
    float3 ba = b - a;
    float3 cb = c - b;
    float3 pa = p - a;
    float3 pb = p - b;
    float3 pc = p - c;
    float check_a = dot(cross(ba, pa), n_triangle);
    float check_b = dot(cross(cb, pb), n_triangle);
    float check_c = dot(cross(ac, pc), n_triangle);
    
    
    if (check_a >= 0 && check_b >= 0 && check_c >= 0) {
        if (p_dist < bestHit.distance && p_dist > 0 ){
            bestHit.material = material;
            bestHit.distance = p_dist;
            bestHit.position = p;
            bestHit.normal = n_triangle;
            return;
        }
    }
}