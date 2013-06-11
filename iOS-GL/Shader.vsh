attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);

    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor  = vec4(0.4, 0.4, 0.8, 1.0);
    vec4 specularColor = vec4(0.6, 0.6, 0.2, 1.0);
    
    // Compute the diffuse and specular shading.
    
    float d =     max(0.0, dot(eyeNormal, lightPosition));
    float s = pow(max(0.0, dot(eyeNormal, lightPosition)), 16.0);
    
    // Compute the resulting material color.
    
    colorVarying = diffuseColor  * d
                 + specularColor * s;
    
    // Transform the vertex.
    
    gl_Position = modelViewProjectionMatrix * position;
}
