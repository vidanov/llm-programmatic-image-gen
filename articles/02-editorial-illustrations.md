---
title: "Editorial Illustrations for $0.04 Each: One Style Document, 13 Consistent Plates"
published: false
description: "A human illustrator quotes $500-3,000 for this scope. Claude on Bedrock did it for $0.52 total, with perfect visual consistency across all plates."
tags: aws, bedrock, design, ai
cover_image: https://labs.p.awsnavigator.com/code-as-canvas/editorial-01-sculptor.svg
canonical_url:
series: "Code as Canvas: LLM Programmatic Image Generation"
---

I needed 13 editorial illustrations for an article series. Same visual language, same color palette, same typographic system. The kind of brief you'd hand a freelance illustrator with a $2,000 budget and a two-week timeline.

I handed it to Claude Sonnet on AWS Bedrock instead. Total cost: $0.52. Time: about 15 minutes including prompt refinement.

## The style document approach

The trick isn't "generate me an image." It's "here is a design system, now produce plates that conform to it."

I wrote a 400-word style document:

```
STYLE: "Subtractive Craft" editorial series
- Warm paper background (#F4ECE1)
- Single accent color: muted blue (#2B5C8E)
- Scientific illustration framing: registration marks, figure numbers
- Monospace captions below each plate
- Conceptual metaphors, not literal depictions
- Ink-line quality: hand-drawn feel via path variation
- NO gradients, NO drop shadows, NO photorealism
- Every plate: 4:3 aspect ratio, 680x510 viewBox
```

Then each plate prompt is one line:

```
Plate I: "The sculptor removing material" — AI editing as subtractive craft
Plate IV: "A leaking bucket" — content that drains value through AI tells
Plate IX: "An iceberg" — the 90% of writing that readers never see
```

## The Bedrock API call

```python
import boto3, json

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')

STYLE_DOC = open('style-system.md').read()

def generate_plate(plate_prompt):
    response = bedrock.invoke_model(
        modelId='us.anthropic.claude-sonnet-5-v1',
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 8192,
            "system": STYLE_DOC,
            "messages": [{
                "role": "user",
                "content": f"Generate SVG for: {plate_prompt}"
            }]
        })
    )
    return json.loads(response['body'].read())['content'][0]['text']

# Generate all 13 plates
plates = [
    "Plate I: The sculptor removing material",
    "Plate III: AI fingerprints on text",
    "Plate IV: A leaking bucket of content value",
    # ... 10 more
]

for i, prompt in enumerate(plates):
    svg = generate_plate(prompt)
    with open(f'editorial-{i+1:02d}.svg', 'w') as f:
        f.write(svg)
```

## Why it stays consistent

The system prompt (style document) acts as a persistent constraint across every call. The LLM doesn't "remember" previous plates, but it doesn't need to. The style document specifies:

1. Exact color values (not "blue" but `#2B5C8E`)
2. Structural rules (registration marks, figure numbers, monospace captions)
3. What to avoid (gradients, shadows, photorealism)
4. Aspect ratio and viewBox dimensions

Each output conforms because the constraints are explicit and measurable. A human reviewer can diff any two plates and verify they share the same DNA.

## The results

Six of the thirteen plates:

![Plate I: The Sculptor](https://labs.p.awsnavigator.com/code-as-canvas/editorial-01-sculptor.svg)

![Plate III: AI Fingerprints](https://labs.p.awsnavigator.com/code-as-canvas/editorial-03-fingerprint.svg)

![Plate IV: The Leaking Bucket](https://labs.p.awsnavigator.com/code-as-canvas/editorial-04-leaking-bucket.svg)

Each SVG is 33-53KB. Each renders at any resolution. Each cost ~$0.04 in Bedrock tokens.

## Cost breakdown

| Item | Cost |
|------|------|
| Style document (system prompt) | ~200 tokens input per call |
| Per-plate prompt | ~20 tokens input |
| Per-plate output | ~1,200 tokens |
| **Cost per plate** (Sonnet) | **~$0.04** |
| **13 plates total** | **$0.52** |

Compare: a freelance illustrator at $150/plate = $1,950 for the same scope. Or stock illustrations that don't match each other = $0 but looks inconsistent.

## What makes this work well

1. **Explicit constraints beat examples.** Telling the LLM "NO gradients" is more reliable than showing it three gradient-free images.
2. **Monospace text in SVGs never breaks.** System font stacks (`ui-monospace, monospace`) render identically everywhere.
3. **Registration marks create instant "editorial" feel.** Four corner crosses + a figure number = it looks intentional and designed.
4. **Conceptual metaphors > literal depictions.** "A sculptor removing material" produces more interesting SVG than "a person editing text."

## When this doesn't work

- You need photorealistic texture (hand-drawn paper grain, ink bleed)
- Each plate must reference specific real objects (product photos, faces)
- The style requires pixel-level precision (drop shadows at specific blur values render differently across SVG engines)

For those cases, use diffusion for the base and overlay programmatic text/data. That's the hybrid approach I cover in article 4.

## Try it

Interactive demo with the full gallery: [labs.p.awsnavigator.com/code-as-canvas](https://labs.p.awsnavigator.com/code-as-canvas/)

Source and all SVGs: [github.com/vidanov/llm-programmatic-image-gen](https://github.com/vidanov/llm-programmatic-image-gen)

Next: architecture diagrams that open clean in draw.io with 270+ verified AWS icon mappings.

---

*[Alexey Vidanov](https://www.linkedin.com/in/vidanov/) · [GitHub](https://github.com/vidanov) · [dev.to](https://dev.to/vidanov)*
