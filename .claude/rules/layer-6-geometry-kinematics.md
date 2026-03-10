# Layer 6 — Geometry & Kinematics

---

## `lib/shapes`

**Purpose:** 3D geometric primitives — planes, lines, segments, boxes, cylinders. Provides intersection, projection, distance, and collision detection operations used by `pose`, `draw`, and `paths`.

### Types (shapes.klt)

```
t_LINE     { point: VECTOR; vec: VECTOR }       -- p = point + vec*t
t_SEGMENT  { r0, r1: VECTOR }                   -- p = (1-t)*r0 + t*r1
t_SEGMENT_XYZ { r0, r1: XYZWPR }
t_PLANE    { normal: VECTOR; d: REAL; origin: VECTOR }   -- normal·xyz + d = 0
t_PLANE2   { normal, d; verts[4]: VECTOR }      -- quadrilateral region
t_BOX      { verts[5], vects[3], normals[3]; centroid: VECTOR }
t_CYLINDER { origin: XYZWPR; radius, height: REAL }
```

### Key API
```
-- Plane construction
shapes__create_plane(origin, normal_vec) : t_PLANE
shapes__create_plane_from_points(p1, p2, p3) : t_PLANE

-- Plane geometry
shapes__plane_intersection_line(pl1, pl2) : t_LINE
shapes__plane_intersection_bicsector(pl1, pl2) : VECTOR
shapes__project_point_on_plane(point, plane) : VECTOR
shapes__distance_of_point_to_plane(point, plane) : REAL

-- 6-point geometry (two planes from 3 points each)
shapes__vector_from_2planes(p1..p6) : VECTOR
shapes__euler_from_2planes(p1..p6) : VECTOR          -- returns WPR Euler angles
shapes__bisector_from_2planes(p1..p6) : VECTOR
shapes__bisector_from_2planes_euler(p1..p6) : VECTOR

-- Collision detection
box.point_collision(p) : BOOLEAN
cylinder.point_collision(p) : BOOLEAN
```

### TP Interfaces
Interactive teach-pendant programs for all major routines (e.g., `shp_splitedv`, `shp_bisecv`, `incylinder`). Accept position register inputs, write results back to registers.

### Dependencies
- `math`, `errors`, `pose`, `ktransw-macros`, `systemlib`

---

## `lib/pose`

**Purpose:** Comprehensive XYZWPR pose manipulation — composition, inversion, interpolation, IK/FK, cylindrical/polar coordinate conversion, quaternion arithmetic, and 4×4 matrix ↔ XYZWPR conversion. Central to the UV→XYZWPR pipeline.

### Sub-modules

| Sub-module | Location | Content |
|------------|----------|---------|
| `poselib` | `lib/poselib/` | Core kinematics, conversions, frame ops, PR I/O |
| `posetp` | `lib/poselib/posetp.kl` | TP-callable arithmetic (add, sub, matmul, frame) |
| `matpose` | `lib/matpose/` | 4×4 rotation/translation matrices |
| `quaternion` | `lib/matpose/quaternion.kl` | Quaternion arithmetic |

### Key API

**poselib — Core Operations**
```
pose__solveIK(pose, grp_no) : JOINTPOS         -- inverse kinematics
pose__solveK(jpos, grp_no) : XYZWPR            -- forward kinematics
pose__correctFrame(crrAxisNo, p1, p2)          -- align tool axis to measured surface normal
    -- Uses quaternion rotation (gimbal-lock free)

pose__cylindrical_to_cartesian(origin, cyl_pose, z_axis)   -- (θ,z,r) → XYZ
pose__cartesian_to_cylindrical(origin, cart_pose, z_axis, radius) : cyl
pose__polar_to_cartesian(origin, pol_pose, z_axis)          -- (θ,ρ,r) → XYZ
pose__cylinder_surf_to_origin()

pose__vector_to_euler(vi, vj, vk, vectorAxis) : XYZWPR
pose__vector_to_euler2(v, vectorAxis) : XYZWPR
pose__vector_to_pose(v, orient, cnf) : XYZWPR
pose__get_orientation(pose) : XYZWPR           -- extract WPR only

pose__find_circle_center(points[]) : VECTOR
pose__find_circumcenter(p1, p2, p3) : T_CIRCLE -- { center, radius }

pose__set/get_posreg_xyz/joint(reg_no, grp_no)
pose__mask_posreg_xyz/orient()                 -- selective register update
pose__get/set_userframe/toolframe(grp_no)

pose__distance(p1, p2) : REAL
pose__jpos_add(J1, J2) : JOINTPOS
```

**posetp — Arithmetic (TP-callable)**
```
posetp__matmul(p1, p2) : XYZWPR          -- pose composition
posetp__add / sub / inv
posetp__scalar_mult/divide/add/subtract
posetp__frame(p1, p2, p3) / frame4 / framevec
posetp__find_center(p1, p2, p3) : XYZWPR -- circumcenter
posetp__dot / cross
posetp__line_increment()                  -- linear interpolation
```

**matpose — 4×4 Matrix Operations**
```
matpose__rotx/roty/rotz(angle) : 4×4 matrix
matpose__transl(x, y, z) : 4×4 matrix
matpose__pose_to_mat(pose) : 4×4 matrix
matpose__mat_to_pose(mat) : XYZWPR
```

**quaternion**
```
quaternion__set(w, x, y, z) / normalize / conj / mult(q1, q2)
quaternion__pose_to_quat(p) / quat_to_pose(q)
quaternion__mat_to_quat / quat_to_mat
```

### Key Types
```
T_CIRCLE   { center: VECTOR; radius: REAL }
t_AXES_FRAME   { orient, approach, normal: VECTOR }
```

### Role in 5-Axis Slicer
- **`pose__correctFrame`** — aligns tool axis perpendicular to print surface using two measured points
- **Cylindrical conversion** — maps (θ, z, r) for printing on curved/rotary-axis surfaces
- **`pose__vector_to_euler`** — converts surface normal vectors into WPR robot orientation commands
- **`posetp__line_increment`** — smooth pose interpolation for path blending
- **matpose** — 4×4 transforms for full frame composition chains

### Dependencies
- `errors`, `Strings`, `math`, `shapes`, `matrix`, `systemlib`, `ktransw-macros`

---

## `lib/sensors`

**Purpose:** Time-of-Flight (ToF) laser distance sensor integration — analog input reading, calibration, rolling-window averaging, edge detection, and spatial scanning.

### Sub-module: `tof/`

**Classes**

`tof_sensor` — single sensor
```
new / delete
set_measurement_type(meas_type)    -- single or averaged
set_sample_time(smpl_tme)
set_sim_analog(meas_mm)            -- simulation mode

read_measurement() : REAL          -- single reading
read_range() : REAL                -- rolling average
read_signal() : BOOLEAN
read_zero() : BOOLEAN

watch_rising_edge() : BOOLEAN
watch_falling_edge() : BOOLEAN
watch_change() : BOOLEAN
```

`scan_part` — spatial scanning integration
```
new / init(crd_sys, crd_axs, orientation)
set_orientation / set_coord_sys / set_scan_finished
```

### Supported Sensors

| Sensor | Range | Sample Time | Input |
|--------|-------|-------------|-------|
| Keyence IL300 | 280mm | 30ms | AI2, ±5V |
| Keyence IL065 | 50mm | 10ms | AI2, ±5V |
| Panasonic MLDS | — | — | config file |

Calibration: linear regression (slope-intercept). Signal/zero detection: virtual (computed) or physical DI pin.

### Dependencies
- `errors`, `math`, `display`, `registers`, `pose`, `pathlib`, `pathmotion`, `csv`, `multitask`, `systemlib`, `Strings`, `ktransw-macros`
