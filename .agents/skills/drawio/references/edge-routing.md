# drawio edge routing & layout cookbook

Load this file when edges in a generated diagram wrap around boxes awkwardly, cross unrelated shapes, or exit from visually wrong sides. The fix is almost always: **give edges explicit connection points, use orthogonal routing, and add waypoints when auto-routing produces crossings.**

---

## Default edge style — copy-pasteable

For architecture diagrams, this is the starting point for every edge:

```
style="edgeStyle=orthogonalEdgeStyle;rounded=1;jettySize=20;endArrow=classic;
       exitX=1;exitY=0.5;entryX=0;entryY=0.5"
```

Then adjust `exitX/Y` and `entryX/Y` per the direction table in [Rule 2](#rule-2--anchor-edges-to-fixed-connection-points).

---

## Practical recipe — build diagrams in this order

The most common failure mode is trying to do everything in one pass. The router cannot fix a layout that is already too cramped. Build in phases:

1. **Define major zones first.** Lay out the container boxes with generous padding. The zones define the diagram's structure and give the router obstacles to route around.
2. **Place boxes inside each zone with generous spacing.** Minimum 40 units between siblings, 60+ where edges need to pass, 100+ between zones.
3. **Add only the main "spine" connections first.** The two or three edges that define the dataflow. Skip the secondary edges until the spine looks right.
4. **Force edge sides with explicit ports.** `exitX/Y` and `entryX/Y` on every spine edge. The router will stop guessing.
5. **Add waypoints only for the handful of problem edges.** Do not waypoint every edge — only the ones the router is crossing through unrelated shapes.
6. **Review crossings and widen corridors before adding more labels.** If two edges still fight over the same corridor, move shapes apart. Labels last, because label layout depends on edge paths being stable.

**Let the diagram breathe.** If boxes are packed tight, orthogonal routing will still look messy no matter how good the XML is. Whitespace around zones and between rows is the single biggest visual win.

---

## Three routing patterns that cover 90% of cases

| Pattern | When | exit / entry |
|---------|------|--------------|
| **Left-to-right pipeline** | Horizontal dataflow inside a zone (Collector → Transforms → Store) | `exitX=1;exitY=0.5` / `entryX=0;entryY=0.5` |
| **Top-to-bottom flow inside a zone** | Vertical dataflow (Scheduler → Rollup → Economics) | `exitX=0.5;exitY=1` / `entryX=0.5;entryY=0` |
| **Cross-zone link** | Edge crossing two zones — add a waypoint in a clear corridor, then enter the target side cleanly | port + `<Array as="points">` waypoint |

---

## Rule 1 — Always set an edge style

Bare edges (`edge="1"` with no `style=`) use the default straight-line router and ignore shape boundaries. Use one of:

| Style | When to use |
|-------|-------------|
| `edgeStyle=orthogonalEdgeStyle;rounded=1` | **Default for architecture diagrams.** Right-angle routing with rounded corners. |
| `edgeStyle=elbowEdgeStyle;elbow=horizontal` | Single L-shape with a horizontal approach. |
| `edgeStyle=elbowEdgeStyle;elbow=vertical` | Single L-shape with a vertical approach. |
| `edgeStyle=isometricEdgeStyle` | Isometric (3D-looking) layouts. |
| `curved=1` (no edgeStyle) | Curved connectors; use sparingly, only for "loose" diagrams. |
| `noEdgeStyle=1` | Force a straight line ignoring the router. Use for cross-zone pointers. |

Always include `rounded=1` with orthogonal routing — 90° corners look dated.

---

## Rule 2 — Anchor edges to fixed connection points

Without `exitX`/`exitY`/`entryX`/`entryY`, drawio auto-picks a side based on the target shape's centroid. Auto-pick frequently chooses the side that causes the edge to cross other shapes.

Pin the exit/entry sides explicitly:

```xml
<mxCell id="e1" edge="1" parent="1" source="A" target="B"
  style="edgeStyle=orthogonalEdgeStyle;rounded=1;
         exitX=1;exitY=0.5;exitDx=0;exitDy=0;
         entryX=0;entryY=0.5;entryDx=0;entryDy=0;
         endArrow=classic">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

**Connection-point coordinate system** (both `exitX/Y` and `entryX/Y`):

```
  (0,0) ──────────── (0.5,0) ──────────── (1,0)
    │                                       │
  (0,0.5)         [shape center]         (1,0.5)
    │                                       │
  (0,1) ──────────── (0.5,1) ──────────── (1,1)
```

Common patterns:

| Direction | exitX/Y on source | entryX/Y on target |
|-----------|-------------------|--------------------|
| Left → right (horizontal flow) | `exitX=1;exitY=0.5` | `entryX=0;entryY=0.5` |
| Right → left (rare) | `exitX=0;exitY=0.5` | `entryX=1;entryY=0.5` |
| Top → bottom | `exitX=0.5;exitY=1` | `entryX=0.5;entryY=0` |
| Bottom → top | `exitX=0.5;exitY=0` | `entryX=0.5;entryY=1` |
| Diagonal approach | `exitX=1;exitY=0` | `entryX=0;entryY=1` |

---

## Rule 3 — Add waypoints when crossings persist

When an edge needs to route around a specific shape that auto-router keeps crossing, insert waypoints:

```xml
<mxCell id="e1" edge="1" parent="1" source="A" target="B"
  style="edgeStyle=orthogonalEdgeStyle;rounded=1;endArrow=classic">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="320" y="400"/>
      <mxPoint x="320" y="520"/>
    </Array>
  </mxGeometry>
</mxCell>
```

Waypoints are absolute coordinates in the diagram frame. The router draws right-angle segments through them in order. Two waypoints define a dogleg, three define a zigzag, etc.

**When to use waypoints:**

- Edge must route around a zone/container.
- Two edges sharing the same source+target need visual separation.
- Edge must enter from a specific side that exit/entry points alone will not force.

---

## Rule 4 — Leave corridors between shapes

Auto-routing needs empty space between boxes. If your layout has two shapes stacked at `y=130` and `y=220` with `height=60` each, there is only 30 units between them. Edges from a third shape that need to route past both will crowd into that corridor.

**Minimum corridors:**

- 40 units between shapes in the same row/column for a single edge
- 60+ units when multiple edges need to pass
- 100+ units between container zones

If the diagram grows, move zones further apart rather than squeezing edges.

---

## Rule 5 — Use `jettySize` to control stub length

Default orthogonal edges exit/enter with a short "stub" before turning. The stub length (`jettySize`) can look cramped when shapes are close:

```xml
style="edgeStyle=orthogonalEdgeStyle;rounded=1;jettySize=20;..."
```

Try 10–30 for most diagrams. Default is `auto` (typically 10).

---

## Rule 6 — Container zones help auto-routing

When you group related shapes in a parent container, drawio's auto-router treats the container as a routing obstacle. Edges entering/leaving the zone will route around the container boundary, not through individual children.

```xml
<mxCell id="zone1" value="BACKEND" parent="1"
  style="rounded=1;fillColor=#f5f5f5;verticalAlign=top;"
  vertex="1">
  <mxGeometry x="100" y="100" width="400" height="300" as="geometry"/>
</mxCell>
<mxCell id="svc1" value="Service A" parent="zone1"
  style="rounded=1;fillColor=#ffffff;"
  vertex="1">
  <mxGeometry x="20" y="40" width="120" height="60" as="geometry"/>
</mxCell>
```

Note `parent="zone1"` on the child, and the child's `mxGeometry` uses coordinates **relative to the parent** (so `x=20` is 20 units inside the zone, not 20 absolute).

**Container grouping is the single biggest win for routing quality.** If your edges are crossing unrelated shapes, check whether you should be grouping shapes into container zones.

---

## Rule 7 — Label edges with background colour

Labels without `labelBackgroundColor` render transparently over whatever line they are on top of — text becomes unreadable when it overlaps the edge or another shape.

```xml
<mxCell id="lbl" value="API call"
  style="text;html=1;strokeColor=none;fillColor=#ffffff;
         align=center;verticalAlign=middle;fontSize=9;
         labelBackgroundColor=#ffffff" vertex="1" parent="1">
  <mxGeometry x="300" y="150" width="80" height="18" as="geometry"/>
</mxCell>
```

Or, simpler — make the label a child of the edge itself:

```xml
<mxCell id="e1" value="API call" edge="1" ...>
```

Edge-native labels auto-position along the edge path and get a white background from the edge's label style.

---

## Rule 8 — Crossings-as-jumps

When edges genuinely must cross each other (rare but unavoidable in dense diagrams), enable line jumps on the edge:

```xml
style="...jumpStyle=arc;jumpSize=10;..."
```

`jumpStyle` options: `none`, `arc` (semicircle), `gap`, `sharp`.

---

## Quick decision tree

When an edge looks wrong:

1. **Does it cross an unrelated shape?** → add `exitX/Y` + `entryX/Y`, or a waypoint at a clear corridor.
2. **Does it exit from the visually wrong side?** → set `exitX/Y` explicitly.
3. **Do multiple edges pile up on the same path?** → separate with different exit/entry Y values (e.g. `exitY=0.25` and `exitY=0.75`).
4. **Does it look cramped?** → increase `jettySize`, or move shapes apart.
5. **Does the label overlap other content?** → set `labelBackgroundColor` or make the label an edge child with `value=`.
6. **Do zones overlap in routing?** → group related shapes in container zones and let the router treat each zone as an obstacle.

---

## Cookbook examples

### Horizontal flow, right-side exits

Left-to-right pipeline (Collector → Transforms → Store):

```xml
<mxCell id="c_t" edge="1" source="collector" target="transforms"
  style="edgeStyle=orthogonalEdgeStyle;rounded=1;
         exitX=1;exitY=0.5;entryX=0;entryY=0.5;
         endArrow=classic">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

### Bottom-up arrow avoiding a zone

From a lower-right shape up to an upper-left shape, routed around the center zone:

```xml
<mxCell id="disp_pw" edge="1" source="dispatch" target="powerwall"
  style="edgeStyle=orthogonalEdgeStyle;rounded=1;
         exitX=0;exitY=0.5;entryX=0.5;entryY=1;
         endArrow=classic;dashed=1">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="340" y="430"/>
      <mxPoint x="170" y="430"/>
    </Array>
  </mxGeometry>
</mxCell>
```

The two waypoints create an L going LEFT then UP, keeping the edge in the left margin rather than crossing through the middle zone.

### Multiple edges sharing an endpoint

Three edges all entering the same target — stagger entry Y positions:

```xml
style="...entryX=0;entryY=0.25;..."
style="...entryX=0;entryY=0.5;..."
style="...entryX=0;entryY=0.75;..."
```
