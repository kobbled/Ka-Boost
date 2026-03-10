# Layer 3 — Data Structures

Generic container and algorithm libraries for Ka-Boost. All use GPP-based generics (`.klt` config + `%class` expansion).

---

## `lib/hash`

**Purpose:** Hash table / dictionary — Karel has no native associative arrays.

### Two Backends

| Backend | Storage | Resize | Location |
|---------|---------|--------|----------|
| Static (`hasharray`) | Fixed `ARRAY[N]` | No — fails when full | `lib/hasharray/` |
| Dynamic (`hashpath`) | `PATH` (linked) | Auto at 80% occupancy | `lib/hashpath/` |

Hash function: Java 1.5-style string hash — `hash = ABS(31 * hash + charOrd)` over each character.

### API (same surface for both)
```
put(key : STRING; value : hval_type; tblProg, tblName : STRING) : BOOLEAN
get(key : STRING; out_val : hval_type; tblProg, tblName : STRING) : BOOLEAN
delete(key : STRING; tblProg, tblName : STRING) : BOOLEAN
clear_table(tblProg, tblName : STRING; clrData : hval_type) : BOOLEAN

-- Dynamic only:
init(tbl : PATH ...)
destructor(tbl : PATH ...)
```

### Built-in Type Variants
`hashstring` (STRING[16]), `hashint` (INTEGER), `hashreal` (REAL), `hashenv` (T_ENV with typ + id). Custom types via `.klt` config defining `HSH_KEY_SIZE`, `hashname`, `hval_def`, `hval_type`.

### Dependencies
- `errors`, `math`, `Strings`, `ktransw-macros`

---

## `lib/hash-registers`

**Purpose:** Register-backed hash — maps symbolic string names to FANUC robot registers (R[], SR[], PR[], F[], DI/DO, AI/AO). Enables named register access with automatic comment labeling.

### Register Value Type
```
hval_def = STRUCTURE
    typ : INTEGER    -- DATA_REG, DATA_POSREG, DATA_STRING, io_dout, io_din, io_flag, etc.
    id  : INTEGER    -- register number / port ID
ENDSTRUCTURE
```

### API
```
hashr__set_hash_table(progName, tableName)    -- target hash location
hashr__set_comments()                         -- write names as register comments
hashr__clear_registers(typ, reset)

hashr__set_int/real/string/io/boolean(name, val)
hashr__get_int/real/string/io/boolean(name) : <type>
```

### Workflow
1. `hashr__set_hash_table(...)` — configure storage
2. `hashenv__put(name, hval_def)` — populate mappings
3. `hashr__set_comments()` — label registers
4. Use getters/setters by name at runtime

### Dependencies
- `ktransw-macros`, `Hash`, `registers`

---

## `lib/queue`

**Purpose:** Template-based FIFO queue and max/min priority queue.

### API
```
-- FIFO Queue
init / push(val) / pop() / empty() / size() / front() / back() / copy(out_path)

-- Priority Queue (additionally)
push(val, priority)    -- higher priority value = dequeued first
pop_min()              -- dequeue lowest priority element
```

### Instantiation Pattern
```
%define class_name myqueue
%include default_queue.klt        -- defines QUEUE_INDEX_TYPE, QUEUETYPE, class_name
%class myqueue(queue.klc)
```

Built-in defaults: `default_queue.klt` (INTEGER FIFO), `default_priority.klt` (INTEGER + INTEGER priority).

### Implementation
Uses Karel `PATH` (linked list). Push = APPEND_NODE, Pop = DELETE_NODE at index 1. Priority queue maintains sorted order on insert.

### Dependencies
- `errors`, `Strings`, `ktransw-macros`, `systemlib`

---

## `lib/iterator`

**Purpose:** Generic sequential iterator — traverses fixed Arrays or dynamic Paths with a cursor.

### Two Variants

| Variant | Storage | Use When |
|---------|---------|----------|
| Array | Fixed `ARRAY[ARRAY_SIZE]` | Static size, direct atomic type |
| Path | Dynamic `PATH` | Variable size, or atomic types needing struct wrapping |

Path iterators wrap atomic values in a struct (e.g. `t_INTEGER { v : INTEGER }`) because Karel PATHs require struct node types. `wrap` / `unwrap` methods handle this transparently.

### API
```
new / delete
push(val) / pop() : val
next() / prev() : val            -- advance cursor, return item
insert(index, val) / get_index(i) / get() / set_index(i)
is_empty() / is_null() / len() : INTEGER

-- Path variant additionally:
wrap(val)                        -- wrap atomic type and push
unwrap() / unwrap_pop / unwrap_next / unwrap_prev
```

### TP Integration
Config `.klt` files define a `ITER_TP_INTERFACE` select-case dispatch. Function enums (RESET, PUSH, POP, INSERT, GET, NEXT, PREV) are passed via `tpe__get_*_arg()` and results returned via `REGMAPPGET` macros to TP registers.

### Dependencies
- `ktransw-macros`, `errors`, `Strings`, `systemlib`, `registers`, `pose`, `TPElib`

---

## `lib/graph`

**Purpose:** Graph traversal, binary search trees, K-D trees, and TSP solving. Used by `pathplan` for optimal path ordering.

### Sub-modules

**Graph** (`include/class/graph/`)
```
new(no_of_verts, directional)
DFS(start_node, pth)             -- depth-first search
BFS(start_node, goal, queue, pth) -- breadth-first search
MST(start_node, pth)             -- Prim's minimum spanning tree
dijkstra_search(start_node, goal, pth)
is_neighbor / list_neighbors / get_adjacencies / put_adjacencies
```
Variants: unweighted, weighted, weighted A*.

**Binary Tree** (`include/class/binary_tree/`)
```
insert / sort / balance
new_generator(typ)               -- IN_ORDER, PRE_ORDER, POST_ORDER
next(data) / print(typ, data)
kthSmallest(k) / kthLargest(k)
```

**KD-Tree** (`include/class/kd_tree/`)
```
create(kd_data, coord_frame) / create_filtered
kth_nearest_neighbors(point, k)   -- k-NN spatial search
radius_nearest_neighbors(point, radius)
kNN_brute_force / rNN_brute_force
findmin / findmax (dimension)
get_query / get_query_arr / get_query_idx
enable_search_filter / disable_search_filter
```

**TSP** (`include/class/TSP/`)
```
new(coord_frame) / init(d, coord_frame)
append(nde) / get_data(out_data)
MST(start_node, out_pth)
NN_graph(k)
```

### Dependencies
- `errors`, `Strings`, `queue`, `math`, `Hash`, `ktransw-macros`, `pathlib`, `systemlib`
