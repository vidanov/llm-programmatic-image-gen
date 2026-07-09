---
title: "From SVG to Unreal Engine: The Renderer Spectrum"
published: false
description: "Every rendering engine that accepts code as input is an LLM target. The browser is the beginning. Game engines are the ceiling. All 100x cheaper than diffusion."
tags: aws, bedrock, gamedev, 3d
cover_image: https://labs.p.awsnavigator.com/code-as-canvas/generative-flow-field.svg
canonical_url:
series: "Code as Canvas: LLM Programmatic Image Generation"
---

The $0.0003 SVG I described in article 1 is the floor. Not the ceiling.

The same pattern (LLM writes code, renderer produces visual) works at every capability tier. Three.js gives you interactive 3D in the browser. Blender gives you photorealistic renders. Unreal Engine 5 gives you film-quality scenes. All from the same Bedrock API call. All at a fraction of diffusion pricing.

## The spectrum

| Renderer | LLM writes | Tokens | Cost | Capability |
|----------|-----------|--------|------|------------|
| SVG (browser) | Markup | ~800 | $0.0003 | 2D vector, animations |
| Canvas 2D (browser) | JavaScript | ~2,400 | $0.001 | Particles, simulations |
| p5.js (browser) | JS sketch | ~1,500 | $0.0006 | Creative/generative art |
| Three.js (browser) | JS scene | ~3,000 | $0.001 | 3D, PBR materials, WebGL |
| Manim (Python) | Scene class | ~2,000 | $0.001 | Math animations, video |
| Godot (.tscn) | Scene text file | ~2,500 | $0.001 | Game scenes, 2D/3D |
| Blender (Python) | bpy script | ~5,000 | $0.002 | Photorealistic 3D |
| Unreal Engine 5 | Python API | ~8,000 | $0.003 | AAA-grade real-time |

Token cost grows linearly (10x from SVG to Unreal). Rendering capability grows exponentially. Even the most expensive option ($0.003 for Unreal-quality) is 7-70x cheaper than diffusion models at $0.02-0.20.

## Why game engines matter

Three properties make game engines ideal LLM targets:

**1. Scene files are human-readable text.**

Godot `.tscn` files are plain text:
```
[gd_scene format=3]
[node name="Player" type="Sprite2D"]
position = Vector2(400, 300)
texture = ExtResource("player_texture")
```

An LLM can write this directly. No API wrapper needed.

**2. Python scripting APIs exist.**

Blender:
```python
import bpy
bpy.ops.mesh.primitive_cube_add(location=(0, 0, 1))
mat = bpy.data.materials.new("Glass")
mat.use_nodes = True
# ... set up PBR material
bpy.ops.render.render(write_still=True)
```

Unreal Engine:
```python
import unreal
actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
    unreal.StaticMeshActor, unreal.Vector(0, 0, 0)
)
```

**3. Headless rendering enables CI/CD.**

```bash
# Blender: render without GUI
blender --background scene.blend --python render_script.py

# Godot: export scene as PNG
godot --headless --export-pack scene.tscn output.png
```

This means the full pipeline (prompt → LLM → code → render → image) runs in a CI job. No human in the loop. No GUI. Automated visual asset generation.

## Live examples

I built two interactive demos to prove this works beyond SVG:

### Three.js Crystal Garden (~3,200 tokens, $0.001)

An LLM wrote a Three.js scene with:
- Procedural crystal geometry (ConeGeometry with random facets and taper)
- MeshPhysicalMaterial with transmission, iridescence, clearcoat
- Unreal Bloom post-processing
- 500 floating particles with additive blending
- Orbit controls (drag to rotate, scroll to zoom)

**[Open it live](https://labs.p.awsnavigator.com/code-as-canvas/threejs-crystal-garden.html)**

The entire scene is ~280 lines of JavaScript. No 3D assets loaded. Every vertex computed from code.

### Particle Universe (~2,400 tokens, $0.001)

Pure Canvas 2D. No WebGL. No library.

- 3 spiral-arm galaxies with orbital mechanics
- 2,600 particles with independent motion
- Click anywhere to create an explosion (150 new particles)
- Mouse attraction (particles drift toward cursor)
- Scroll to zoom

**[Open it live](https://labs.p.awsnavigator.com/code-as-canvas/particle-universe.html)**

## The Bedrock call is the same

Whether you're generating SVG or a Blender script, the API call is identical:

```python
response = bedrock.invoke_model(
    modelId='us.anthropic.claude-sonnet-5-v1',
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 8192,
        "messages": [{
            "role": "user",
            "content": "Write a Three.js scene: procedural crystal garden with bloom post-processing, orbit controls, and floating particles. Self-contained HTML file."
        }]
    })
)
```

The only difference is token count (800 for SVG vs 3,000 for Three.js vs 8,000 for Unreal). The economics still dominate: $0.001-0.003 vs $0.02-0.20.

## The skill reuse multiplier

The real savings come on image 2 through 1,000.

When the LLM writes a rendering "skill" (a reusable template, shader, or scene structure), the first image costs full generation price. Every subsequent image costs only the prompt delta.

Example from this project: Claude Fable wrote a 500-line Python crayon-art renderer ($0.40 for skill creation). Each subsequent crayon illustration costs only the 20-token prompt describing what to draw (~$0.0001).

| Image number | Cost (diffusion) | Cost (programmatic) |
|--------------|-----------------|-------------------|
| 1 | $0.034 | $0.40 (skill creation) |
| 2 | $0.034 | $0.0001 |
| 10 | $0.34 | $0.401 |
| 100 | $3.40 | $0.41 |
| 1,000 | $34.00 | $0.50 |

By image 12, programmatic wins. By image 100, it's 8x cheaper. By image 1,000, it's 68x cheaper.

## What this means for production

If your application generates visual content at scale (dashboards, reports, product configurators, educational content, game assets), the "LLM writes code → engine renders" pattern turns image generation from a variable cost into an effectively fixed cost.

The renderer already exists. You're already paying for the LLM. The only question is whether you point it at a diffusion API or at a rendering engine's input format.

## Source and demos

- Full demo: [labs.p.awsnavigator.com/code-as-canvas](https://labs.p.awsnavigator.com/code-as-canvas/)
- Source: [github.com/vidanov/llm-programmatic-image-gen](https://github.com/vidanov/llm-programmatic-image-gen)

Next: multi-pass consistency testing. Same prompt, four Claude models, three passes each. How repeatable is the output?

---

*[Alexey Vidanov](https://www.linkedin.com/in/vidanov/) · [GitHub](https://github.com/vidanov) · [dev.to](https://dev.to/vidanov)*
