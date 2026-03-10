# Layer 1 — Core Utilities

Foundation utilities used by virtually every other module.

---

## `lib/errors`

**Purpose:** Centralized error handling and variable initialization. Almost every module calls `karelError` or `CHK_STAT`.

### Key API

```
CHK_STAT(rec_stat : INTEGER)
    -- If status ≠ SUCCESS, posts an ABORT-level error

karelError(stat : INTEGER; errStr : STRING; errorType : INTEGER)
    -- 0 = WARNING, 1 = WARNING + history, 2 = ABORT
    -- Writes to TPDISPLAY, posts to TP history

SET_UNINIT_I/R/B/V/F/S(progname, varname)
    -- Initialize uninitialized variables; swallows error 12311

SET_UNI_ARRS(progname, varname, start_i, stop_i)
    -- Initialize a range of array elements by name
```

### Named Error Codes (errors.klt)

Categories: array, path, value, type, position, file, task, TPE (teach pendant editor), config, queue.

Notable: `ARR_LEN_MISMATCH`, `INVALID_INDEX`, `VAR_UNINIT`, `FILE_NOT_OPEN`, `TPE_PROGRAM_DOES_NOT_EXIST`, `QUEUE_IS_EMPTY`, `POS_TYPE_MISMATCH`, `SEARCH_MOTION_FAILED`

### Dependencies
- `Strings` (for `str_parse` — line-wrapping error messages to fit TP display)

---

## `lib/system`

**Purpose:** Robot controller interface layer — time/date, leader frames (dual-arm), shared type definitions, and system variable macros used across all modules.

### Key API

```
system__date() : STRING          -- 'DD-MMM-YYYY'
system__time() : STRING          -- 'HH:MM:SS'

system__set_leader_frame(cd_pair_no, ldr_frm_no, frm)
system__get_leader_frame(cd_pair_no, ldr_frm_no) : XYZWPR
system__mask_leader_frame(cd_pair_no, ldr_frm_no, axs, val)

system__pns_to_str() : STRING    -- maps input pins → program name
system__int_to_bool(int) : BOOLEAN
system__tdata_glte(data1, data2, typ, comparator) : BOOLEAN

VEC(x, y, z) : VECTOR
VEC2D(x, y) : VECTOR             -- z = 0
compare_VEC(v1, v2, tolerance) : BOOLEAN
```

### Important Types (systemlib.datatypes.klt)

```
t_DATA_TYPE -- union: holds INT, REAL, STRING, BOOL, VEC, POSE, CONFIG
t_INTEGER, t_REAL, t_STRING16, t_BOOL, t_VECTOR, t_POSE  -- atomic wrappers
VECTOR2D, VECTOR2Di
```

### System Variable Macros (systemvars.klt)

`ZEROPOS(g)`, `ZEROARR`, `TOTAL_GROUPS`, `GROUP_KINEMATICS(g)`, `CURRENT_UTOOL`, `CURRENT_UFRAME`, `DYNAMIC_LEADER(f,l)`

### Constants (systemlib.codes.klt)

Type codes: `C_INT`, `C_REAL`, `C_STR`, `C_BOOL`, `C_VEC`, `C_POS`, `C_POSEXT`, `C_CONFIG`
Comparators: `C_GREATER`, `C_LESSER`, `C_EQUAL`, `C_GREATEREQL`, `C_LESSEREQL`

### Dependencies
- `Strings`, `ktransw-macros`

---

## `lib/Strings`

**Purpose:** All string operations Karel lacks natively — splitting, searching, trimming, type conversions (to/from STRING), path parsing, register-to-string formatting.

### Key API

**Splitting / Parsing**
```
split_str(str, delim, out_arr[])
extract_str(str, start_delim, stop_delim) : STRING
rev_split(str, delim, out_arr[])
char_index(str, chr) : INTEGER
takeStr(str, chr) : STRING          -- before char
takeNextStr(str, chr) : STRING      -- after char
search_str(str, sub) : INTEGER
getIntInStr(str) : INTEGER
```

**Trimming / Formatting**
```
lstrip / rstrip / lstripChar / rstripChar / delim_strip
to_upper(str) : STRING
str_parse(str, max_len, out_arr[])  -- split for TP display line-wrapping
```

**Path Utilities**
```
splitext(path) : STRING    -- filename without extension
get_ext(path) : STRING
basename(path) : STRING
get_device(path) : STRING
get_progname(ref) : STRING -- from '[progname]varname' format
get_varname(ref) : STRING
```

**To-String Conversions**
```
i_to_s(i) : STRING
r_to_s(r) : STRING
b_to_s(b) : STRING
p_to_s(pose) : STRING          -- multi-line XYZWPR
pose_to_s(pose, delim) : STRING
vec_to_s(v, delim) : STRING
joint_to_s(jpos, delim) : STRING
rarr_to_s / iarr_to_s / sarr_to_s (arr, delim) : STRING
i_to_byte(i) : STRING          -- binary string
```

**From-String Conversions**
```
s_to_i / s_to_r / s_to_b
s_to_xyzwpr / s_to_vec / s_to_joint / s_to_config
s_to_arr / s_to_rarr / s_to_iarr
bin_to_i(bin_str) : INTEGER
```

**Validation**
```
charisnum(c) : BOOLEAN
strisreal / strisint (str) : BOOLEAN
delim_check(delim) : BOOLEAN
```

### Dependencies
- `errors`, `systemlib`, `TPElib`, `ktransw-macros`
