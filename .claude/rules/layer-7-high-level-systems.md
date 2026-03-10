# Layer 7 — High-Level Systems

The three modules at this layer implement the end-to-end 5-axis DLP 3D printing slicer pipeline.

---

## `lib/draw`

**Purpose:** 2D canvas and polygon manipulation — converts 2D slice geometry (from SVG/DXF) into rasterized vector tool paths. First stage of the slicer pipeline.

### Sub-modules

| Sub-module | Location | Purpose |
|------------|----------|---------|
| `drawlib` | `lib/drawlib/` | Core 2D geometric algorithms |
| `canvas` | `lib/canvas/` | OOP canvas manager (collections of polygons) |
| `polygon` | `lib/polygon/` | OOP polygon with pattern generation |

### Key Types (draw.klt)

```
t_VERTEX     -- polygon vertex with topology: nextPoly, prevPoly, polygon index, type flags
t_SEGMENT2D  -- 2D line segment (parametric: r0, r1)
t_SEG2D_POLY -- rasterized line + parent polygon ID + tangent vector
t_RECT       -- oriented bounding rectangle: corners[4], axes[2], center
t_RASTER     -- { angle, line_width, pitch, direction }
t_VEC_PATH   -- vector path node (for contours)
t_VERT_CLIP  -- clipped vertex for line-polygon intersection
```

### Key API

**drawlib — Core Algorithms**
```
draw__raster_lines(polygon, raster_params, out_lines[])   -- fill with parallel lines
draw__trace(polygon, out_contours[])                       -- boundary contour
draw__intersect(seg1, seg2, alpha1, alpha2) : BOOLEAN      -- line-line intersection
draw__convex_hull(points[], out[]) / draw__convex_hull_arr
draw__bounding_box(points[]) : t_RECT
draw__inset_polygon(polygon, offset, out[])
draw__rotate_polygon(polygon, angle, out[])
draw__scale_polygon(polygon, sx, sy, out[])
draw__point_collision_polygon(p, polygon) : BOOLEAN
draw__psuedo_center(polygon) : VECTOR
draw__calc_tangent / draw__calc_tangent_segment
draw__hexagon(center, radius, out[])

-- 2D ↔ 3D coordinate mapping
draw__vec_to_vec2d / draw__vec2d_to_vec
draw__vec2d_to_pos / draw__pos_to_vec2d
draw__angle_to_vector / draw__vector_to_angle
draw__perpendicular_vector
```

**canvas — OOP Canvas**
```
canvas__new/init/delete
canvas__append_polygon / append_vertex
canvas__raster(raster_params) / canvas__trace
canvas__rotate_canvas / scale_polygons / inset_polygons
canvas__set_canvas / flip_canvas
canvas__get_lines / get_contours
canvas__lines_to_vec_path / contours_to_vec_path
```

**polygon — OOP Polygon**
```
polygon__init/delete
polygon__makePad / makeHex / makeCustom(layout_file)
polygon__rotate / scale / inset / copy(n, spacing)
polygon__draw(raster_params)
polygon__get_lines / get_contours
```

### Python Utilities
- `utils/dxf/` — DXF → CSV conversion scripts
- `utils/svg/` — Custom SVG parser (`svgpy`) for path extraction
- `utils/slices/` — Polygon clipping via Python Clipper library
- `viz/` — Matplotlib debug visualization for geometry

### Build Note
Delete `paths.pc` on the controller before loading `draw.pc`. `srtclp.pc` (sort class) may need manual FTP upload.

### Dependencies
- `shapes`, `math`, `pose`, `pathlib`, `layout`, `Strings`, `errors`, `csv`, `ktransw-macros`, `systemlib`

---

## `lib/layout`

**Purpose:** Generic template-based buffered file reader — deserializes structured CSV (or G-code) slicer output into typed Karel PATH buffers. Supports layer-by-layer and pass-by-pass buffering strategies.

### Key API
```
new(fname) / delete
openfile / closefile
clear_buffer

loadBuffer() : BOOLEAN        -- load next buffer; TRUE = more data remains
bufferLength() : INTEGER
get_index_base() : INTEGER     -- 0 or 1 array indexing
get_buffer_cycles() : INTEGER  -- number of completed load cycles
get_current_index() : INTEGER  -- current line number in file
get_counter() / reset_counter
countInstances(out_pth)        -- user-defined instance enumeration
```

### Buffering Strategies (`.klt` configs)

| Config | Strategy |
|--------|----------|
| `pathlayer_by_layer.klt` | One buffer per Z-layer |
| `pathlayer_by_pass.klt` | One buffer per pass within a layer; reads XML metadata for structure |

Buffer condition (when to flush) is user-defined per config. Data is loaded into a `PATH` buffer and consumed by `pathlayer`.

### Dependencies
- `csv`, `errors`, `Strings`, `systemlib`, `ktransw-macros`, `xml`

---

## `lib/paths` _(core slicer system)_

**Purpose:** End-to-end pipeline from 2D vector paths to executed robot motion. Converts UV-parameterized slice geometry into XYZWPR robot commands. Supports Cartesian, cylindrical, and polar coordinate systems across multiple Z-layers with laser/powder hardware control.

---

### Sub-packages

#### `lam` — Laser-Assisted Manufacturing Parameters

Hardware parameter definitions for the deposition head:

```
t_LASER     { power: REAL }
t_POWDER    { wps_no, rpm, lpm, flow_rate, height: REAL; powder_type: INTEGER }
t_HOPPERS   { hopper1, hopper2: t_POWDER }
t_DEPTHREGR { a, b, c: REAL }    -- quadratic: a·x² + b·x + c for z-height compensation
```

Dependencies: `ktransw-macros`, `registers`

---

#### `pathlib` — Core Path Data Structures

**Path types:**
```
t_VEC_PATH    -- vector + path_code + polygon_id
t_POS_PATH    -- XYZWPR position node
t_TOOLPATH    -- XYZWPR + speed + motion_type
```

**Path codes** (matplotlib-compatible):
`PTH_MOVETO`, `PTH_LINETO`, `PTH_CURVE3` (quadratic Bézier), `PTH_CURVE4` (cubic Bézier), `PTH_CLOSE`

**Coordinate systems:** `PTH_CARTESIAN`, `PTH_CYLINDER`, `PTH_POLAR`

**Raster types:** `ONEWAY`, `ZIGZAG`, `NEARESTNEIGHBOR`, `BOTTOMFILL`, `CASCADEFILL`

**Key routines:**
```
interpolate_vpath / vpath_to_pos
raster_neighbors / compute_diagonals
filter_polygon / calc_bounding_box / map_to_bounding_box
cylindrical_to_cartesian / polar_to_cartesian
set_speed / set_orientation
```

Dependencies: `ktransw-macros`, `errors`, `systemlib`, `math`, `pose`, `draw`

---

#### `pathplan` — Path Planning (Segment Ordering)

Uses graph algorithms to determine optimal traversal order for path segments.

```
new / init(coord_frame)
importPath / append_path
get_plan() : INTEGER[]          -- ordered segment indices

MST(start_node, out_pth)        -- Minimum Spanning Tree tour
NN_graph(k)                     -- k-Nearest Neighbor graph
raster_graph()                  -- optimized raster line ordering

next_path / get_toolpath_segment  -- iterator interface
is_path_end() : BOOLEAN
```

Dependencies: `ktransw-macros`, `errors`, `systemlib`, `math`, `graph`, `pose`, `csv`

---

#### `pathmake` — Path Generation & Interpolation

Converts planned path segments into dense motion point clouds with speed profiles.

```
new / init(coord_frame, origin, path_planner)
next_toolpath / get_toolpath
makeline(start, end, spacing)
interpolate_toolpath(segment, spacing)    -- linear + Bézier interpolation
set_segment_speed_bounds(start_spd, end_spd)
planPath / planImportPath
```

Dependencies: `pathlib`, `pathplan`, `pose`, `draw`, `registers`

---

#### `pathmotion` — Robot Motion Execution

Issues actual TP move commands to the robot. Pluggable interface supports 6-axis robot, rotary, and positioner configurations.

```
-- motion (base class)
new / init
set_tool_offset / set_speeds / set_interpolation
set_coord_frame / set_idod

-- robotmotion (inherits motion)
move / moveLine / moveArc / movePos
movePoly / movePolyFull / movePolyArc
run_approach_path / run_retract_path
moveApproach / moveRetract
```

Interface template: `motion.interface.klt` — swap between robot/rotary/positioner without changing caller code.

Dependencies: `pathlib`, `pathmake`, `pose`, `math`, `draw`, `registers`

---

#### `pathlayer` — Layer-by-Layer Orchestration

Coordinates multi-layer printing — iterates Z-layers and passes, controls laser/powder hardware, manages `layout` file loading.

```
new / init(layer_params, pass_params)
next_layer / next_pass
import_layout / open_layout / close_layout

set_drawing_type(typ)     -- LINES, CONTOURS, RASTER, etc.
set_start_layer(n)

lam_start / lam_stop      -- laser/powder hardware hooks
```

Dependencies: `pathlib`, `pathmake`, `pathmotion`, `layout`, `lam`, `pose`, `math`

---

#### `pathforms` — TP UI Forms for Operator Input

FANUC form definitions (`.ftx`) for operator parameter entry:

| Form | Purpose |
|------|---------|
| `gsstateg.ftx` | State / configuration |
| `gspptheg.ftx` | Path parameters |
| `gsppadeg.ftx` | Pad pattern |
| `gsphexeg.ftx` | Hexagonal pattern |
| `gspcuseg.ftx` | Custom path |

Dependencies: `pathlib`, `pathmake`, `pathmotion`, `lam`, `display`, `forms`

---

#### `pathgen` — Path Generator / TP Iterator

Minimal bridge between offline path planning and online TP execution.

Dependencies: `ktransw-macros`, `errors`, `systemlib`

---

### UV → XYZWPR Conversion Pipeline

```
[2D Slice Geometry]
        │ SVG/DXF import (Python utils)
        ▼
    lib/draw
    canvas + polygon → t_VEC_PATH (MOVETO/LINETO/CURVE3/CURVE4/CLOSE codes)
        │
        ▼
    pathplan
    Graph-based segment ordering (MST / NN / raster)
        │ ordered segment indices
        ▼
    pathmake
    Interpolate at fixed spacing → t_TOOLPATH (XYZWPR + speed per point)
    Coordinate conversion: Cartesian / Cylindrical / Polar
        │
        ▼
    pathmotion
    Issue TP move commands (MOVE_LINE / MOVE_CIRC / MOVE_SCEN)
        │
        ▼
    pathlayer
    Iterate Z-layers → control lam hardware (laser power, powder feed)
```
