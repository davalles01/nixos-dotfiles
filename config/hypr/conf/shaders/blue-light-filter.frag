#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Reducción de la luz azul
    pixColor.b *= 0.65; // Reduce el canal azul
    pixColor.g *= 0.88; // Ajusta levemente el verde para un tono cálido suave

    fragColor = pixColor;
}
