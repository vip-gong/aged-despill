#version 330 core

// Uniforms
uniform sampler2D foregroundTex;
uniform sampler2D backgroundTex;
uniform int screenType; // 0 for Green, 1 for Blue

// Inputs and Outputs
in vec2 TexCoord;
out vec4 FragColor;

vec3 aged_despill(vec3 color, float alpha, int type) {
    // Alpha gating: early exit for opaque/interior pixels
    if (alpha <= 0.001 || alpha >= 0.999) {
        return color;
    }
    
    vec3 result = color;
    
    if (type == 0) { // Green screen
        if (color.g > color.r && color.g > color.b) {
            result.g = max(color.r, color.b);
        }
    } else { // Blue screen
        if (color.b > color.r && color.b > color.g) {
            result.b = max(color.r, color.g);
        }
    }
    
    return result;
}

void main() {
    vec4 fg = texture(foregroundTex, TexCoord);
    vec3 bg = texture(backgroundTex, TexCoord).rgb;
    
    // Apply AGED before compositing (assumes straight alpha)
    vec3 despilled = aged_despill(fg.rgb, fg.a, screenType);
    
    // Standard alpha composite
    vec3 finalColor = mix(bg, despilled, fg.a);
    
    FragColor = vec4(finalColor, 1.0);
}