# Layer 2 — Math & Linear Algebra

---

## `lib/math`

**Purpose:** Extended math functions absent from Karel's standard library. Provides trig wrappers, logarithms, rounding, arc operations, quicksort, random number generation, vector algebra, and rotation matrices.

### Key API

**Missing Karel Built-ins**
```
math__pow(base, exp) : REAL
math__log10(x) / math__log2(x) : REAL
math__floor(x) / math__ceil(x) / math__round(x) : REAL
math__decimal(num, digits) : STRING     -- formatted real with N decimal places
math__cosh(x) / math__sinh(x) : REAL
math__atan2(y, x) / math__atan_pos(y, x) : REAL
```

**Arc & Angle**
```
math__arclength(radius, degrees) : REAL
math__arcangle(arc_len, radius) : REAL
math__map_to_360(angle) : REAL
```

**Array Operations**
```
math__max_real / math__min_real / math__max_real_index / math__min_real_index
math__max_int  / math__min_int  / math__max_int_index  / math__min_int_index
math__sum_real / math__average_real
math__quicksort_real / math__quicksort_int
math__map_real(val, in_min, in_max, out_min, out_max) : REAL
math__bitmask(n) : INTEGER             -- 2^(n-1)
```

**Random Number Generation** (linear congruential PRNG)
```
math__srand(seed)
math__rand() : REAL                    -- [0.0, 1.0]
math__rand_range(lo, hi) : REAL
math__rand_int(lo, hi) : INTEGER
math__rand_position / math__rand_vector / math__rand_rarr
```

**Vector Math**
```
math__norm(v) / math__norm2(v) : REAL
math__proj(v, axis) / math__proj_orthoganal / math__proj_length
math__average_vector(arr[]) : VECTOR
math__manhattan_dist(v1, v2) : REAL
```

**Rotation / Translation**
```
math__translate(pose, vec) : XYZWPR
math__rotx / math__roty / math__rotz (pose, angle) : XYZWPR
math__rotx_vec / math__roty_vec / math__rotz_vec (vec, angle) : VECTOR
```

**Generic Sort Classes** (in `include/classes/`)
- `arraysort.klc` — array sorting / deduplication
- `pathsort.klc` — PATH-based list sorting / deduplication with custom comparator

### Constants (math.klt)
`M_PI`, `M_E`, `M_PI_2`, `M_2PI`, `M_SQRT2`, `M_LN2`, `M_LN10`, `M_LOG2E`, `M_LOG10E`, `M_RAD2DEG`, `M_DEG2RAD`, `EPSILON=0.0001`, `MAX_INT`, `MAX_BYTE`

### Dependencies
- `Strings`, `errors`, `systemlib`, `ktransw-macros`

---

## `lib/matrix`

**Purpose:** 1D array and 2D matrix operations. 4×4 matrices are critical for homogeneous coordinate transforms in 5-axis kinematics.

### Key API

**1D Operations**
```
matrix__zeros_1D / matrix__ones_1D / matrix__full_1D / matrix__random_1D
matrix__linspace(start, stop, n, out[])
matrix__eye(n, out[])
matrix__shift_s / matrix__shift_r (arr, n)      -- shift up / down
matrix__add_1D / matrix__sub_1D / matrix__mul_1D / matrix__div_1D
```

**2D Matrix Class** (template — specify size via `.klt` config)
```
zeros / ones / full / random / eye
add / subtract / smult(scalar) / mult(mat2) / transpose
inverse / det / cofactor / trace
set_row / set_from_array / get_col / convert_to_array / clear
create_array_from_string / create_row_from_string
```

### Available Template Sizes

| Template | Dimensions | Primary Use |
|----------|-----------|-------------|
| `carr3` | 3×3 | rotation matrices |
| `carr4` | 4×4 | homogeneous transforms (position + rotation) |
| `carr10` | 10×10 | general |
| `carr23` | 2×3 | general |
| `carr305` | 30×5 | path data |

The 4×4 template (`carr4`) is most important for robotics — it represents full rigid body transforms T = R·t, enabling frame composition, inverse kinematics, and tool orientation math.

### Dependencies
- `math`, `errors`, `ktransw-macros`
