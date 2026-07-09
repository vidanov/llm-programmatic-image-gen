# Programmatic Visualization Skill

> Drop this into any LLM-based workflow (Claude Projects, Kiro, custom agents) as a system prompt or skill file. It teaches the model to generate visuals by writing rendering code instead of calling image generation APIs.

## What This Does

When you ask for a visual, this skill routes the request to the right approach:

- **Code-rendered** (SVG, Canvas, Three.js, Blender, Godot, Manim): for diagrams, animations, generative art, 3D scenes, data viz. Deterministic, editable, $0.004-0.10/image.
- **Diffusion model** (DALL-E, GPT Image, Midjourney): for photorealistic images, people, hand-drawn styles. $0.01-0.20/image.

## Usage

**As a Claude Project instruction:** paste the entire skill section below into your project's custom instructions.

**As a Kiro skill:** save as `.kiro/skills/programmatic-viz/SKILL.md` with the frontmatter below.

**As a system prompt:** prepend to any LLM conversation where you want visual generation capabilities.

---

## Skill Definition

```yaml
name: programmatic-viz
description: >-
  Generate visuals by writing rendering code. Routes requests to the correct
  approach: diffusion models for photorealistic/artistic images, or code
  generation (SVG, Canvas 2D, Three.js, Blender, Godot, Manim) for diagrams,
  animations, visualizations, and technical content. Activates on any request
  to create a visual, image, illustration, diagram, animation, or 3D scene.
```

---

## Core Principle

The LLM writes code. The renderer produces the visual. The renderer is free. The output is deterministic, editable, version-controllable, and scalable.

## Step 0: Diffusion or Code?

Before generating anything, classify the request:

**Use a diffusion/image-generation model when:**
- User wants a picture OF something concrete (animal, person, scene, object)
- Children's/crayon/hand-drawn style requested
- Photorealistic output needed
- Artistic styles requiring pixel texture (watercolor, oil painting, etc.)
- Keywords: "cute", "draw me a", "picture of", "photo of", "painting of"

**Write rendering code when:**
- Technical diagrams, data visualizations, charts
- Architecture/system diagrams
- Blog illustrations that are abstract/metaphorical
- Animated SVGs, particle effects, generative art
- 3D scenes (procedural geometry)
- Hero images/banners for repos or articles
- Math animations, educational visualizations
- Interactive demos

**Heuristic:** "picture of [concrete noun]" → diffusion. "visualize [concept]" → code.

## Renderer Selection

| Need | Renderer | Output | Tokens | Cost |
|------|----------|--------|--------|------|
| Blog/article illustration, visual metaphor | SVG editorial | `.svg` | ~1,200 | $0.0005 |
| Technical diagram (network, infra, data flow) | SVG technical | `.svg` | ~2,400 | $0.001 |
| Hero image for README or presentation | SVG generative | `.svg` | ~1,800 | $0.0007 |
| Blog hero banner (wide, 2:1 aspect) | SVG hero | `.svg` | ~2,200 | $0.0009 |
| Interactive demo or teaching visualization | Canvas 2D | `.html` | ~2,400 | $0.001 |
| Particle systems, physics simulations | Canvas 2D | `.html` | ~2,400 | $0.001 |
| 3D product shot, spatial scene, PBR materials | Three.js | `.html` | ~3,200 | $0.001 |
| Math explanation, animated proof | SVG animated | `.svg` | ~2,000 | $0.001 |
| Creative/generative art, algorithmic beauty | p5.js or SVG | `.html`/`.svg` | ~1,500 | $0.0006 |
| Photorealistic 3D render | Blender Python | `.py` | ~5,000 | $0.002 |
| Game scene, 2D/3D level | Godot .tscn | `.tscn` | ~2,500 | $0.001 |
| Video/animation export | Manim Python | `.py` | ~2,000 | $0.001 |

**Decision heuristic:** Start at SVG (simplest, cheapest). Move up only when the concept requires interactivity, 3D, or physics that SVG cannot express.

## Visual Style DNA

### Light Green (default)

```
Background:    #f4f9f6 (light mint-white)
Card/panel:    #ffffff
Primary:       #16a34a (green-600)
Secondary:     #22c55e (green-500)
Tertiary:      #4ade80 (green-400)
Accent:        #14532d (green-900, for text/headers)
Text:          #1a2e23 (dark green-ink)
Muted:         #5a7065 (secondary text)
Lines/grid:    #cde5d6 (light green border)
Tint:          #e8f5ec (green-50, backgrounds)
```

### Dark Technical (use when requested or for terminal/space themes)

```
Background:    #050a07 → #0a1510 → #0d1f15 (gradient)
Primary:       #22c55e (green)
Secondary:     #4ade80 (light green)
Tertiary:      #059669 (teal-green)
Accent:        #6366f1 (indigo, for contrast elements)
Text:          #e8f5ec (light)
Muted:         #6b8a74 (secondary text)
Grid/lines:    #1e3a5f or #22c55e at 0.06-0.1 opacity
Glow filter:   feGaussianBlur stdDeviation 2-8
```

### Warm Editorial (for article illustrations)

```
Background:    #F1EBDF (warm paper)
Ink:           #1C1811
Accent warm:   #B8860B, #CD853F, #8B4513
Accent cool:   #2C5F7C, #4A7C59
Texture:       Hundreds of tiny circles (r: 0.4-1.1, opacity: 0.02-0.06) as paper grain
```

### Style Constants

- **Animations:** `<animate>` with `dur` 1.5-6s, `repeatCount="indefinite"`, subtle opacity/radius pulses
- **Glow effects:** `<filter>` with `feGaussianBlur` (stdDeviation 2 for tight, 4-8 for ambient)
- **Grid underlays:** Very low opacity (0.04-0.1), stroke-width 0.5
- **Typography:** `ui-monospace, monospace` for labels/stats, serif for math
- **Labels:** Max 1-5 words, positioned as overlays, never dominating
- **Aspect ratios:** 800x600 (standard), 800x400 (hero/banner), 800x500 (presentation), 1600x1200 (editorial)

## Renderer Templates

### SVG Editorial Illustration

For blog articles, conceptual metaphors, abstract compositions.

Structure:
1. Paper-textured background (`#F1EBDF` + 50-100 tiny grain circles)
2. Central metaphorical composition (geometric shapes representing the concept)
3. Layered depth (3-5 planes of overlapping translucent circles/shapes)
4. Subtle animation (1-2 pulsing elements, not distracting)
5. No text inside the SVG (or max 1-2 words as accent)

Key technique — paper grain effect:
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="1200" viewBox="0 0 1600 1200">
  <rect width="1600" height="1200" fill="#F1EBDF"/>
  <!-- Scatter 50-100 tiny circles for paper texture -->
  <circle cx="541" cy="227" r="0.86" fill="#1C1811" opacity="0.023"/>
  <circle cx="853" cy="457" r="0.44" fill="#1C1811" opacity="0.040"/>
  <!-- ... many more ... -->
  <!-- Central composition here -->
</svg>
```

### SVG Technical Diagram

For system architectures, neural networks, data flows.

Structure:
1. Dark gradient background
2. Subtle grid underlay (opacity 0.04-0.08)
3. Ambient glow circles (radialGradient + blur filter)
4. Main diagram elements (nodes, connections, labels)
5. Animated signal pulses along paths

Key technique — animated signal pulses:
```svg
<circle r="3" fill="#22c55e" opacity="0.9">
  <animateMotion dur="3s" repeatCount="indefinite" 
    path="M50,100 L150,100 L150,150 L300,150"/>
</circle>
```

### SVG Generative / Hero

For README heroes, presentation backgrounds, flow fields.

Structure:
1. Background with subtle grid
2. Large ambient glow blobs (radialGradient + blur filter)
3. Math-driven Bezier curves with varying stroke-opacity
4. Particle scatter (small circles with varying opacity)
5. Breathing animations on glow elements

### Canvas 2D (Interactive HTML)

For particle systems, simulations, physics visualizations.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #000; overflow: hidden; }
    canvas { display: block; }
    #hud {
      position: fixed; top: 20px; left: 20px;
      font-family: ui-monospace, monospace;
      color: #e8f5ec; font-size: 11px;
      background: rgba(0,0,0,0.6);
      padding: 16px; border-radius: 8px;
    }
  </style>
</head>
<body>
  <div id="hud"><!-- stats overlay --></div>
  <canvas id="c"></canvas>
  <script>
    const canvas = document.getElementById('c');
    const ctx = canvas.getContext('2d');
    // Resize, particle class, physics, requestAnimationFrame
  </script>
</body>
</html>
```

Conventions:
- HUD overlay with key stats
- Mouse/touch interaction
- Resize handler for full viewport
- 60fps with `requestAnimationFrame`
- No external dependencies

### Three.js (3D HTML)

For 3D scenes, product shots, spatial concepts.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <style>/* dark bg, monospace overlay */</style>
</head>
<body>
  <div id="overlay"><!-- stats --></div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
  <script>
    // Scene, camera, renderer, procedural geometry, materials, animation
  </script>
</body>
</html>
```

Conventions:
- Three.js from CDN (pinned version)
- Procedural geometry only (no loaded assets)
- OrbitControls for interaction
- Self-contained, opens in any browser

### SVG Math/Education Animation

Key technique — self-drawing curves:
```svg
<path d="..." stroke="#a5b4fc" stroke-width="2" fill="none">
  <animate attributeName="stroke-dashoffset" from="1200" to="0" dur="3s" 
    fill="freeze" repeatCount="indefinite"/>
  <animate attributeName="stroke-dasharray" from="0 1200" to="1200 0" dur="3s" 
    fill="freeze" repeatCount="indefinite"/>
</path>
```

### Blender Python

```python
import bpy
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
# Create geometry, materials, lights, camera
# bpy.ops.render.render(write_still=True)
```

Run: `blender --background --python script.py`

### Godot Scene

Output `.tscn` text file:
```
[gd_scene format=3]
[node name="Root" type="Node2D"]
[node name="Player" type="Sprite2D" parent="."]
position = Vector2(400, 300)
```

## Process

1. **Classify** — diffusion or code? (Step 0)
2. **Select renderer** — cheapest that can express the concept
3. **Choose palette** — light green default, dark if requested, warm for editorial
4. **Generate** — complete, self-contained code
5. **Verify** — valid XML/HTML, no broken deps, animations work

## Output Conventions

- Every file opens by dragging into a browser (HTML/SVG) or running directly (Python)
- Zero build steps, zero install requirements (except renderer for Blender/Godot)
- SVGs include `xmlns` and proper `viewBox`
- HTML files are complete `<!DOCTYPE html>` documents
- No external fonts or images

## Diffusion Style Presets

When routing to an image generation model, append these to the prompt:

**Crayon / Children style:**
> Please create the entire image as a single painting in a crayon art style. Simplify the details, making it look like it was drawn by a 10-year-old child. Give it the feel of being drawn on a sheet of white paper, with a very cute vibe, and you can add some adorable elements like flowers, candies, stars, clouds, etc., to make it look innocent and childlike.

**Photorealistic:**
> Photorealistic, highly detailed, professional photography, natural lighting, sharp focus, 8K resolution.

**Watercolor:**
> Soft watercolor painting style, gentle color bleeding, visible paper texture, artistic brush strokes, muted palette.

**Technical illustration:**
> Clean technical illustration style, precise lines, labeled components, cross-section view, engineering drawing aesthetic.

## Cost Comparison

At 10,000 images/month:

| Method | Cost/image | Monthly |
|--------|-----------|---------|
| GPT Image 1.5 | $0.034 | $340 |
| gpt-image-1-mini | $0.011 | $110 |
| **LLM → SVG** | $0.0006 | $6 |
| **LLM → Three.js** | $0.001 | $10 |
| **LLM → Blender** | $0.002 | $20 |

## License

MIT. Part of the [LLM Programmatic Image Generation](https://github.com/vidanov/llm-programmatic-image-gen) project.
