#version 460

in vec2 inPosition;
out vec2 fragTexCoord;

uniform Transform {
    mat4 transform;
};

void main() {
    gl_Position = vec4(inPosition * 2.0 - 1.0, 0.0, 1.0);
    fragTexCoord = (transform * vec4(vec2(inPosition.x, 1.0 - inPosition.y), 0.0, 1.0)).xy;
}