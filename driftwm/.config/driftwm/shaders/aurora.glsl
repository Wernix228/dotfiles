// Aurora — северное сияние в палитре Catppuccin Mocha над звёздным небом:
// зелёные и бирюзовые ленты с лёгкой сиреневой каймой сверху, как у настоящего.
// Ленты медленно текут (u_time), звёзды и сияние привязаны к холсту (u_camera),
// поэтому при панорамировании небо едет вместе с окнами.
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform vec2 u_camera;
uniform float u_time;

const vec3 BASE     = vec3(0.118, 0.118, 0.180); // #1e1e2e
const vec3 CRUST    = vec3(0.067, 0.067, 0.106); // #11111b
const vec3 MAUVE    = vec3(0.796, 0.651, 0.969); // #cba6f7
const vec3 BLUE     = vec3(0.537, 0.706, 0.980); // #89b4fa
const vec3 TEAL     = vec3(0.580, 0.886, 0.835); // #94e2d5
const vec3 GREEN    = vec3(0.651, 0.890, 0.631); // #a6e3a1
const vec3 SKY      = vec3(0.537, 0.863, 0.922); // #89dceb
const vec3 LAVENDER = vec3(0.706, 0.745, 0.996); // #b4befe

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
    float sum = 0.0, amp = 0.5;
    mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
    for (int i = 0; i < 4; i++) {
        sum += amp * noise(p);
        p = rot * p * 2.03;
        amp *= 0.5;
    }
    return sum;
}

// Одна лента сияния: волнистая горизонтальная полоса с вертикальными «лучами»
float band(vec2 p, float offset, float t) {
    float wave = fbm(vec2(p.x * 0.55 + t * 0.6, offset)) * 2.2 - 1.1;
    float d = abs(p.y - offset - wave * 0.9);
    float body = exp(-d * d * 10.0);
    float rays = 0.55 + 0.45 * noise(vec2(p.x * 7.0 + t * 1.5, offset * 3.0));
    float curtain = smoothstep(0.0, 1.2, (p.y - offset - wave * 0.9) + 1.0); // мягкий хвост вниз
    return body * rays * mix(0.6, 1.0, curtain);
}

float stars(vec2 p, float t) {
    vec2 cell = floor(p);
    vec2 f = fract(p) - 0.5;
    float h = hash(cell);
    if (h < 0.93) return 0.0;
    vec2 jitter = vec2(hash(cell + 7.1), hash(cell + 3.7)) - 0.5;
    float d = length(f - jitter * 0.7);
    float twinkle = 0.6 + 0.4 * sin(t * (1.5 + h * 3.0) + h * 40.0);
    return smoothstep(0.08, 0.0, d) * twinkle * (h - 0.93) * 14.0;
}

void main() {
    vec2 world = v_coords * size + u_camera;   // пиксели холста, Y вниз
    vec2 p = world / 360.0;
    float t = u_time * 0.08;

    // Небо: сверху темнее (crust), к низу экрана чуть светлее (base)
    vec3 col = mix(CRUST, BASE, smoothstep(-0.2, 1.1, v_coords.y));

    // Звёзды в двух слоях разной плотности
    col += LAVENDER * stars(world / 38.0, u_time) * 0.9;
    col += vec3(1.0) * stars(world / 71.0 + 13.0, u_time * 0.7) * 0.7;

    // Ленты повторяются по вертикали каждые 4 единицы холста (~1440 px)
    float py = mod(p.y + 1.0, 4.0) - 2.0;
    vec2 q = vec2(p.x, py);
    float b1 = band(q, -1.1, t);
    float b2 = band(q + vec2(3.7, 0.0), -0.1, t * 1.3 + 4.0);
    float b3 = band(q + vec2(9.1, 0.0), 0.9, t * 0.8 + 9.0);

    // Цвет ленты плывёт по палитре вдоль X
    float hueShift = fbm(vec2(p.x * 0.25 - t, py * 0.2));
    // Пастель Catppuccin чуть насыщеннее, чтобы сияние «светилось», а не туманилось
    vec3 vivid = vec3(0.25, 0.95, 0.62);
    vec3 green = mix(GREEN, vivid, 0.45);
    vec3 teal  = mix(TEAL, vec3(0.2, 0.9, 0.85), 0.35);
    vec3 c1 = mix(green, teal, smoothstep(0.3, 0.7, hueShift));
    vec3 c2 = mix(teal, SKY, smoothstep(0.35, 0.75, hueShift));
    vec3 c3 = mix(green, teal, smoothstep(0.25, 0.65, hueShift));

    col += c1 * b1 * 0.8 + c2 * b2 * 0.55 + c3 * b3 * 0.45;

    // Сиреневая кайма над лентами — верхний край сияния
    float fringe = band(q + vec2(0.0, 0.55), -1.1, t) + band(q + vec2(3.7, 0.55), -0.1, t * 1.3 + 4.0);
    col += mix(MAUVE, BLUE, hueShift) * fringe * 0.16;

    // Лёгкая дымка, чтобы ленты не выглядели «нарисованными»
    col += TEAL * fbm(p * 1.7 + t) * 0.025;

    gl_FragColor = vec4(col, 1.0);
}
