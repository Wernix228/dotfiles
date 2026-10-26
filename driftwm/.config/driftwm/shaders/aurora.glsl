// Aurora — северное сияние в палитре Catppuccin Mocha над звёздным небом:
// зелёные и бирюзовые ленты с лёгкой сиреневой каймой сверху, как у настоящего.
//
// Сияние привязано к экрану (v_coords), а не к холсту: при любом зуме и положении
// это одно цельное небо без повторов и стыков. Движение холста чувствуется через
// параллакс: при панорамировании вбок ленты медленно плывут, звёзды смещаются
// сильнее. Звёзды экранного размера и не растут при зуме.
precision highp float;

// Яркость сияния: 1.0 — сочно, 0.5 — спокойный фон под окнами
const float AURORA = 0.5;
// Насыщенность поверх пастели Catppuccin: 0 — чистая пастель, 0.45 — «светится»
const float VIVID = 0.2;

varying vec2 v_coords;
uniform vec2 size;
uniform vec2 u_camera;
uniform float u_zoom;
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

// Лента сияния: волнистая полоса на высоте center с вертикальными «лучами»
// и мягким шлейфом вниз. p.y — доля высоты экрана (0 сверху, 1 снизу).
float band(vec2 p, float center, float seed, float t) {
    float wave = (fbm(vec2(p.x * 0.9 + t * 0.6, seed)) - 0.5) * 0.45;
    float d = p.y - center - wave;
    float body = exp(-d * d * 90.0);
    float tail = exp(-max(d, 0.0) * 9.0) * smoothstep(-0.02, 0.06, d) * 0.45;
    float rays = 0.5 + 0.5 * noise(vec2(p.x * 14.0 + t * 1.5, seed * 3.0));
    return (body + tail) * rays;
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
    float aspect = size.x / size.y;
    float t = u_time * 0.08;

    // Камера в экранных пикселях: при зуме один и тот же сдвиг холста — разный сдвиг на экране
    vec2 cam = u_camera * u_zoom;

    // Небо: сверху темнее (crust), к низу чуть светлее (base)
    vec3 col = mix(CRUST, BASE, smoothstep(-0.2, 1.1, v_coords.y));

    // Звёзды экранного размера, два слоя с разным параллаксом
    vec2 px = v_coords * size;
    col += LAVENDER * stars((px + cam * 0.12) / 38.0, u_time) * 0.9;
    col += vec3(1.0) * stars((px + cam * 0.05) / 71.0 + 13.0, u_time * 0.7) * 0.7;

    // Сияние: координаты в долях экрана, по X — бесконечный шум с лёгким параллаксом
    vec2 q = vec2(v_coords.x * aspect + cam.x / size.y * 0.04, v_coords.y);
    float b1 = band(q, 0.34, 1.0, t);
    float b2 = band(q + vec2(2.3, 0.0), 0.22, 5.0, t * 1.3 + 4.0);
    float b3 = band(q + vec2(6.1, 0.0), 0.47, 9.0, t * 0.8 + 9.0);

    // Цвет ленты плывёт по палитре вдоль X; пастель Catppuccin чуть насыщеннее,
    // чтобы сияние «светилось», а не туманилось
    float hueShift = fbm(vec2(q.x * 0.6 - t, 0.5));
    vec3 green = mix(GREEN, vec3(0.25, 0.95, 0.62), VIVID);
    vec3 teal  = mix(TEAL, vec3(0.2, 0.9, 0.85), VIVID * 0.8);
    vec3 c1 = mix(green, teal, smoothstep(0.3, 0.7, hueShift));
    vec3 c2 = mix(teal, SKY, smoothstep(0.35, 0.75, hueShift));
    vec3 c3 = mix(green, teal, smoothstep(0.25, 0.65, hueShift));

    col += (c1 * b1 * 0.8 + c2 * b2 * 0.55 + c3 * b3 * 0.45) * AURORA;

    // Сиреневая кайма над лентами — верхний край сияния
    float fringe = band(q, 0.30, 1.0, t) + band(q + vec2(2.3, 0.0), 0.18, 5.0, t * 1.3 + 4.0);
    col += mix(MAUVE, BLUE, hueShift) * fringe * 0.14 * AURORA;

    // Лёгкая дымка у горизонта
    col += TEAL * fbm(q * 2.0 + t) * 0.025 * smoothstep(0.3, 1.0, v_coords.y);

    gl_FragColor = vec4(col, 1.0);
}
