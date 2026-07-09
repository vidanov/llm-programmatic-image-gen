#!/bin/bash
# Organize the repo structure for GitHub publishing
# Run from: /Users/a.vidanov/Documents/PROJECTS/LLM-Programmatic-Image-Gen
set -e

echo "Organizing repo structure..."

# Create directories
mkdir -p examples/editorial
mkdir -p benchmarks/crayon-comparison
mkdir -p benchmarks/multi-pass

# Move example files to examples/
mv demo.html examples/ 2>/dev/null || true
mv presentation.html examples/ 2>/dev/null || true
mv threejs-crystal-garden.html examples/ 2>/dev/null || true
mv particle-universe.html examples/ 2>/dev/null || true
mv generative-flow-field.svg examples/ 2>/dev/null || true
mv manim-sine-wave.svg examples/ 2>/dev/null || true
mv isometric-data-center.svg examples/ 2>/dev/null || true
mv neural-network-viz.svg examples/ 2>/dev/null || true
mv circuit-board-hero.svg examples/ 2>/dev/null || true
mv procedural-landscape.svg examples/ 2>/dev/null || true

# Move editorial SVGs
mv editorial-*.svg examples/editorial/ 2>/dev/null || true

# Move benchmark PNGs
mv crayon-skill-*.png benchmarks/crayon-comparison/ 2>/dev/null || true
mv chatgpt-crayon-reference.png benchmarks/crayon-comparison/ 2>/dev/null || true
mv gpt-image-mini-reference.png benchmarks/crayon-comparison/ 2>/dev/null || true
mv crayon-art.png benchmarks/crayon-comparison/ 2>/dev/null || true
mv aws-arch-example.png benchmarks/ 2>/dev/null || true

# Move benchmark-results/ contents if they exist
if [ -d "benchmark-results" ]; then
  mv benchmark-results/*pass*.png benchmarks/multi-pass/ 2>/dev/null || true
  mv benchmark-results/*.png benchmarks/crayon-comparison/ 2>/dev/null || true
  rmdir benchmark-results 2>/dev/null || true
fi

echo "✓ Structure organized"
echo ""
echo "Ready for git:"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Initial commit: Code as Canvas'"
echo "  gh repo create vidanov/llm-programmatic-image-gen --public --source=. --push"
echo ""
echo "After push:"
echo "  1. Upload docs/social-preview.svg as repo Social Preview (Settings > Social preview)"
echo "  2. Set About: 'LLMs write rendering code. Existing engines produce the image. 100x cheaper than diffusion.'"
echo "  3. Topics: llm, svg, image-generation, aws-bedrock, three-js, generative-art, blender, cost-optimization"
