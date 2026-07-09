---
title: "Architecture Diagrams That Don't Break: 270+ Verified AWS Icons for draw.io"
published: false
description: "AI agents generate broken architecture diagrams because stencil names are wrong. This skill carries 270+ verified icon mappings and enforces layout rules."
tags: aws, architecture, drawio, ai
cover_image: https://labs.p.awsnavigator.com/code-as-canvas/aws-arch-example.png
canonical_url:
series: "Code as Canvas: LLM Programmatic Image Generation"
---

Every time an AI agent generates an AWS architecture diagram for draw.io, the same thing happens: half the icons render as empty white boxes. The service names in the prompt don't match the stencil identifiers in draw.io's AWS library.

I spent two weeks mapping every AWS service to its correct draw.io stencil path, current as of July 2026. The result is a skill file that any AI agent can read, and it solves the problem permanently.

## The problem, visualized

Ask any LLM to generate a draw.io diagram with DynamoDB:

```xml
<!-- What the LLM writes -->
<mxCell style="shape=image;image=mxgraph.aws4.dynamodb_table" .../>

<!-- What draw.io actually needs -->
<mxCell style="shape=image;image=mxgraph.aws4.dynamodb" .../>
```

`dynamodb_table` renders as an empty box. `dynamodb` renders the correct icon. Multiply this across 50+ commonly-used services, add renamed services (Elasticsearch → OpenSearch, still uses the old stencil), and you get diagrams that look broken by default.

## The solution: a reference file the LLM reads

The [aws-architecture-diagram-skill](https://github.com/vidanov/aws-architecture-diagram-skill) is a markdown file containing:

1. **270+ verified stencil mappings** (service name → exact `mxgraph.aws4.*` path)
2. **Layout rules** (left-to-right flow, 78px icon size, minimum spacing)
3. **Color conventions** (strokeColor per service category)
4. **XML structure template** (valid mxGraphModel skeleton)

No MCP server. No Python package. No binary to install. Just a markdown file any agent can read as a system prompt or skill.

## Installation

For Kiro / Claude-based agents:
```bash
npx skills add vidanov/aws-architecture-diagram-skill
```

For any other LLM (ChatGPT, Cursor, Copilot): paste the reference file content into your system prompt or custom instructions.

## How it works with Bedrock

```python
import boto3, json

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')
skill_content = open('aws-architecture-diagram-skill.md').read()

response = bedrock.invoke_model(
    modelId='us.anthropic.claude-sonnet-5-v1',
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 8192,
        "system": skill_content,
        "messages": [{
            "role": "user",
            "content": "Create an event-driven order processing architecture with API Gateway, SQS, Lambda, DynamoDB, EventBridge, Step Functions, and SNS."
        }]
    })
)

drawio_xml = json.loads(response['body'].read())['content'][0]['text']

with open('architecture.drawio', 'w') as f:
    f.write(drawio_xml)
# Open in draw.io — every icon renders correctly
```

**Result**: a `.drawio` file that opens clean. Every icon resolves. Layout follows AWS architecture diagram conventions. Editable in draw.io's free editor.

## Token cost

- Input (skill + prompt): ~850 tokens
- Output (12-node diagram): ~1,200 tokens
- **Total cost**: ~$0.0003 (Flash) to ~$0.005 (Sonnet)

The diagram is free to edit afterward. No re-generation needed for changes.

## Why stencil names are wrong

draw.io's AWS library was built over years as services were added and renamed:

| Service (2026 name) | You'd guess | Actual stencil |
|---------------------|-------------|----------------|
| DynamoDB | `dynamodb_table` | `dynamodb` |
| OpenSearch | `opensearch` | `elasticsearch_service` |
| Step Functions | `step_functions` | `step_functions` ✓ (one of the few) |
| EventBridge | `eventbridge` | `eventbridge` ✓ |
| ElastiCache | `elasticache` | `elasticache` ✓ |
| Application Load Balancer | `alb` | `application_load_balancer` |
| CloudWatch | `cloudwatch_2` | `cloudwatch` |

Without the mapping, every diagram is a guessing game. With it, the LLM writes correct identifiers every time.

## Layout rules that matter

The skill enforces conventions that make diagrams readable:

- **Left-to-right flow** (clients left, data stores right)
- **78px icon size** (standard for AWS architecture diagrams)
- **Minimum 100px spacing** between nodes
- **Orthogonal edges** with rounded corners
- **Service category colors**: compute (orange), database (purple), integration (pink), networking (purple)

These rules come from AWS's own architecture diagram guidelines. When the LLM follows them, the output looks professional without manual adjustment.

## Live example

The interactive demo shows a real-time editing loop: the diagram re-renders as the LLM modifies the XML (swapping icons, adding nodes, renaming labels):

**[labs.p.awsnavigator.com/code-as-canvas](https://labs.p.awsnavigator.com/code-as-canvas/demo.html#archdiagram)**

## Comparison to alternatives

| Tool | Cost | Editable after | Icons correct | Opens in draw.io |
|------|------|----------------|---------------|------------------|
| **This skill** | $0.0003-0.005 | Full XML source | 270+ verified | Yes |
| ChatGPT image gen | $0.034 | No (PNG) | N/A | No |
| Mermaid | Free | Text source | No AWS icons | No |
| Lucidchart AI | $9/mo subscription | Yes | Partial | Export only |
| Manual draw.io | Free (time cost) | Yes | Yes | Yes |

The programmatic approach gives you the editability of manual draw.io with the speed of AI generation and the accuracy of a verified reference catalog.

## Source

- Skill repo: [github.com/vidanov/aws-architecture-diagram-skill](https://github.com/vidanov/aws-architecture-diagram-skill)
- Full demo: [labs.p.awsnavigator.com/code-as-canvas](https://labs.p.awsnavigator.com/code-as-canvas/)
- All examples: [github.com/vidanov/llm-programmatic-image-gen](https://github.com/vidanov/llm-programmatic-image-gen)

Next: the renderer spectrum. The same principle (LLM writes code, engine renders) works with Three.js, Blender, Godot, and Unreal Engine.

---

*[Alexey Vidanov](https://www.linkedin.com/in/vidanov/) · [GitHub](https://github.com/vidanov) · [dev.to](https://dev.to/vidanov)*
