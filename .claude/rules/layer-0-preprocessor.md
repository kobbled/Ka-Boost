# Layer 0 — Build & Preprocessor

The single module in this layer has no Ka-Boost dependencies. Every other module depends on it directly or transitively.

---

## `lib/ktransw-macros`

**Purpose:** GPP macro definitions that bring object-oriented patterns to Karel — namespacing, header guards, generic type/class instantiation, and multi-dimensional array helpers.

### Key Macro Files

| File | Purpose |
|------|---------|
| `standard.m` | `ASIS(x)`, `SILENT(x)` — basic substitution control |
| `define_type.m` | `t_arr2d`, `t_arr3d`, `t_hash`, `call_path_type`, `define_type_class`, `concat` |
| `namespace.m` | `funcname(f)`, `classfunc(f)`, `declare_function(...)`, `declare_member(...)` — scoped `module__routine` naming |
| `header_guard.m` | `header_guard`, `header_if`, `header_def` — prevent double inclusion |
| `type_guard.m` | `type_guard`, `type_if`, `type_def` |
| `include_header.m` | `header_file(n)` |
| `include_types.m` | `type_file(n)`, `include_type` |

### How Namespacing Works

The `declare_function` and `declare_member` macros mangle routine names to `module__routine` (double underscore). This is how all Ka-Boost public APIs are named:

```
declare_function(pose, matmul, pos, mul)
-- generates both `pose__matmul` and short alias `pos__mul`
```

### How Generics Work

GPP is used as a C-style preprocessor. To instantiate a generic class:

1. Create or use a `.klt` config that defines template parameters (e.g. `QUEUE_INDEX_TYPE`, `class_name`)
2. `%include` the config before expanding
3. Use `%class classname(template.klc)` to expand the class body

```
%define class_name myqueue
%include default_queue.klt
%class myqueue(queue.klc)
```

### Karel File Types Supported

`.kl` source, `.klc` class (template), `.klt` type definitions, `.klh` headers, `.m` GPP macros
