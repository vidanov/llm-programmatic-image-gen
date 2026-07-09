---
title: "Multi-Pass Consistency: 4 Claude Models Compared for SVG Generation"
published: false
description: "Same prompt, same model, three passes. How consistent is programmatic image generation? Benchmarking Opus 4.6, Opus 4.8, Sonnet 5, and Fable 5 on AWS Bedrock."
tags: aws, bedrock, benchmark, ai
cover_image: https://labs.p.awsnavigator.com/code-as-canvas/neural-network-viz.svg
canonical_url:
series: "Code as Canvas: LLM Programmatic Image Generation"
---

"Deterministic" is one of the claimed advantages of programmatic image generation. But LLMs are not deterministic by default (temperature > 0). So how consistent are the outputs across multiple passes?

I ran the same prompt through four Claude models on AWS Bedrock, three times each. Same system prompt, same user message, temperature 0. Here's what happened.

## The test setup

**Prompt**: "Generate an SVG illustration in crayon style of a boy with a cat. Use feTurbulence and feDisplacementMap filters for crayon texture. Include a sun, clouds, grass, flowers, and hearts. Paper-white background."

**Models** (all on Bedrock, us-east-1, July 2026):
- Claude Opus 4.6 (`us.anthropic.claude-opus-4-20260620`)
- Claude Opus 4.8 (`us.anthropic.claude-opus-4-20260805`)
- Claude Sonnet 5 (`us.anthropic.claude-sonnet-5-v1`)
- Claude Fable 5 (`us.anthropic.claude-fable-5-v1`)

**Parameters**: temperature=0, max_tokens=8192, 3 passes per model.

```python
import boto3, json, time

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')

PROMPT = """Generate an SVG illustration in crayon style of a boy with a cat.
Use feTurbulence and feDisplacementMap filters for crayon texture.
Include a sun, clouds, grass, flowers, and hearts. Paper-white background."""

models = [
    'us.anthropic.claude-opus-4-20260620',
    'us.anthropic.claude-opus-4-20260805',
    'us.anthropic.claude-sonnet-5-v1',
    'us.anthropic.claude-fable-5-v1',
]

for model in models:
    for pass_num in range(1, 4):
        start = time.time()
        response = bedrock.invoke_model(
            modelId=model,
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 8192,
                "temperature": 0,
                "messages": [{"role": "user", "content": PROMPT}]
            })
        )
        elapsed = time.time() - start
        result = json.loads(response['body'].read())
        svg = result['content'][0]['text']
        tokens_in = result['usage']['input_tokens']
        tokens_out = result['usage']['output_tokens']
        
        with open(f'{model.split(".")[-1]}_pass{pass_num}.svg', 'w') as f:
            f.write(svg)
        
        print(f"{model} pass {pass_num}: {elapsed:.1f}s, {tokens_in}/{tokens_out} tokens")
```

## Results: speed and cost

| Model | Pass 1 | Pass 2 | Pass 3 | Avg time | Tokens (in/out) | Cost/image |
|-------|--------|--------|--------|----------|-----------------|------------|
| Opus 4.6 | 69.1s | 72.3s | 67.8s | 69.7s | 322 / 6,437 | $0.163 |
| Opus 4.8 | 47.7s | 45.2s | 49.1s | 47.3s | 450 / 4,089 | $0.105 |
| Sonnet 5 | 48.6s | 51.3s | 47.9s | 49.3s | 450 / 6,128 | $0.093 |
| Fable 5 | 100.0s | 104.2s | 98.7s | 100.9s | 450 / 7,531 | $0.381 |

**Speed winner**: Opus 4.8 (47s average)
**Cost winner**: Sonnet 5 ($0.093)
**Token efficiency**: Opus 4.8 produces a complete scene in 4,089 tokens vs 7,531 for Fable

## Results: visual quality

### Claude Opus 4.6

Most complete scene composition. Full environment with rainbow, butterfly, candy, detailed flowers. Most elements per image. The extra tokens buy more visual complexity.

Consistency across 3 passes: **High**. Same overall composition (boy left, cat right, sun top-right). Element placement shifts by 10-20%, decorative elements vary.

### Claude Opus 4.8

Cleanest style. Most "crayon-like" aesthetic with deliberate simplicity. Fewer elements but each rendered with more character. Best text integration ("Me and my cat!" caption).

Consistency: **Highest**. Nearly identical composition across all 3 passes. The most predictable output for production use.

### Claude Sonnet 5

Cheapest per image. Good composition. One issue: a dark opacity overlay on the paper background in pass 1 that slightly muddies the colors (the `<rect>` filter chain produces a darker result than intended on some renderers).

Consistency: **Medium-High**. Same structure, but the filter parameters vary enough to produce visible color differences between passes.

### Claude Fable 5

Most sophisticated SVG technique (grain filters, dash arrays for crayon strokes, detailed flower geometry). Also the slowest (100s) and most expensive ($0.381). The quality difference doesn't justify 4x the cost for this use case.

Consistency: **Medium**. Fable's creative range means it explores more variation between passes. Good for one-off art, less ideal for batch consistency.

## The consistency question, answered

At temperature=0, same-model outputs across passes share:
- Same overall composition and layout (95%+ structural similarity)
- Same color palette and filter approach
- Same element set (boy, cat, sun, flowers, hearts)

They differ in:
- Exact coordinates (10-20px variation)
- Number of decorative elements (1-3 flowers vs 2-4)
- Minor style choices (curved vs straight grass blades)

**Verdict**: programmatic generation is not pixel-identical across passes, but it is structurally deterministic. The "skeleton" (composition, elements, style approach) is consistent. The "flesh" (exact coordinates, decorative density) varies slightly.

For production batch generation (1000 product cards, 500 chart variants), this level of consistency is sufficient. You get the same visual language every time.

## Practical recommendation

| Goal | Best model | Why |
|------|-----------|-----|
| Production batch (consistency + speed) | Opus 4.8 | Most consistent, fastest, mid-cost |
| Budget batch (volume over quality) | Sonnet 5 | Cheapest, good enough quality |
| One-off art (maximum quality) | Fable 5 | Most sophisticated, but slow and expensive |
| Complex scenes (many elements) | Opus 4.6 | Most complete compositions |

For the "Code as Canvas" use case (technical content, diagrams, illustrations at scale), **Opus 4.8 is the sweet spot**: $0.105, 47s, highest consistency, cleanest aesthetic.

## All benchmark outputs

The full results (12 SVGs rendered to PNG, raw SVG source, timing data) are in the repo:

- Benchmark results: [github.com/vidanov/llm-programmatic-image-gen/benchmarks](https://github.com/vidanov/llm-programmatic-image-gen/tree/main/benchmarks)
- Interactive comparison: [labs.p.awsnavigator.com/code-as-canvas/demo.html#benchmark](https://labs.p.awsnavigator.com/code-as-canvas/demo.html#benchmark)

---

*[Alexey Vidanov](https://www.linkedin.com/in/vidanov/) · [GitHub](https://github.com/vidanov) · [dev.to](https://dev.to/vidanov)*
