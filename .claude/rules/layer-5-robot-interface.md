# Layer 5 — Robot Interface

Modules that directly interface with the FANUC robot controller hardware, TP programs, and the teach pendant UI.

---

## `lib/registers`

**Purpose:** Abstraction over all FANUC register types with bidirectional Karel ↔ TP synchronization.

### Register Types Covered

| Type | Description |
|------|-------------|
| `R[n]` | Numeric registers (INTEGER or REAL) |
| `SR[n]` | String registers |
| `PR[n]` | Position registers (XYZWPR or JOINTPOS) |
| `F[n]` | Flags (BOOLEAN) |
| `DI/DO[n]` | Digital I/O |
| `AI/AO[n]` | Analog I/O |
| `RI/RO[n]` | Robot I/O |
| `GI/GO[n]` | Group I/O |
| `UI/UO[n]` | User-defined I/O |
| `SI/SO[n]` | Serial I/O |

### Key API
```
registers__get_int/real/string/io/boolean(reg_no) : <type>
registers__set_int/real/string/io/boolean(reg_no, val)
registers__is_real/int(reg_no) : BOOLEAN
registers__get/set_comment(typ, id, cmt)
registers__clear_comments(typ, reset_reg)
registers__get_type_enum/name(typ_str)

-- TP bridging (registerstp.kl)
registerstp__get/set_karel_int/real/bool/string/xyz/joint()
```

### regmap Class (`lib/regmap.klc`)
Maps Karel struct fields to TP registers bidirectionally. Configured via `.klt` files using macros:
```
map_select_getter(progname, varname, 'R', 2, 'field_name', 'INTEGER')
map_select_getter(progname, varname, 'PR', 4, 'pose_field', 'XYZWPR')
```

### Dependencies
- `errors`, `pose`, `systemlib`, `TPElib`, `ktransw-macros`

---

## `lib/display`

**Purpose:** TP (Touch Panel) output, keyboard input, register display, and severity-level logging with color coding.

### Architecture
1. **`display.kl`** — core TP print + input routines
2. **`printlib.kl`** — logging wrappers with severity + file output
3. **`dispclass.klc`** — OOP logger class

### Key API
```
display__clear / display__show
display__print(str) / display__print_line(str)
display__input_string/int/real(prompt_msg)
display__keyboard / display__alpha
display__string_reg/register/posreg/io (reg_no, show_reg)

printlib__init_log(showdebug, showinfo)
printlib__log_string(msg_typ, s)
printlib__log_numreg/posreg/io (msg_typ, reg_no, ...)
printlib__log_open / log_close
```

### Severity Levels (dispclass)
`WARN=0`, `ERR=1`, `DEBUG=2`, `INFO=3`, `HEAD=4` — color-coded output (red=error, yellow=warn, green=debug, blue=info)

### Constraints
- Max 40 chars/line for TP display (`MAX_DISPLAY_LENGTH`)
- Max 100 chars for file output (`MAX_FILE_LENGTH`)
- Pipe buffer: max 500 lines (`set_maxlines`)

### Dependencies
- `errors`, `systemlib`, `files`, `registers`, `Strings`, `ktransw-macros`

---

## `lib/multitask`

**Purpose:** Spawn, monitor, and abort concurrent Karel tasks. Thin wrapper over `RUN_TASK`, `PAUSE_TASK`, `ABORT_TASK`, `GET_TSK_INFO`.

### Key API
```
task__thread(task_name) : BOOLEAN
task__thread_motion(task_name, grp_mask) : BOOLEAN
    -- grp_mask: binary bits — bit 0=GP1, bit 1=GP2, bit 2=GP3, bit 3=GP4
task__wait(task_name) : BOOLEAN
    -- polls every 100ms, max 20× (2-second timeout)
task__is_task_running/done/parent_of (task_name) : BOOLEAN
task__abort / task__abort_motion (task_name) : BOOLEAN
```

### Constants (multitask.klt)
`MAX_CHECK_DELAY = 100` ms, `MAX_STATUS_CHECKS = 20`

### Dependencies
- `errors`, `ktransw-macros`

---

## `lib/TPE`

**Purpose:** Read, write, parse, and programmatically generate Fanuc TP (Teach Pendant) programs from Karel. Acts as the bridge between Karel path planning and TP motion execution.

### Sub-modules

**tpefile** — Low-level TP file operations
```
tpe__open/close/copy/create (TPE_name)
tpe__write_end / write_pause / write_uframe(n) / write_utool(n)
tpe__copy_header_ls / write_from_ls
tpe__get_open_id(name) : TPEPROGRAMS
tpe__ls_exists(name) : BOOLEAN
tpe__get_int/real/string/boolean/vector_arg(reg_no)   -- read TP AR[] params
tpe__parameter_exists(reg_no) : BOOLEAN
```

**tpepose** — OOP pose and motion manipulation
```
get_cart_pose/joint_pose (TPE_name, pose_no) : DATA_TYPE
set_cart_pose/joint_pose (TPE_name, pose_no, pose)
get_last_pose_index(TPE_name) : INTEGER
get_cart_poses/joint_poses (TPE_name, poses : PATH)
set_tpe_poses(TPE_name, cart_poses, joint_poses)
copy_cart_poses/joint_poses / multi_cart_poses
parse_motion(line) : t_MOTIONSTAT
get_motion_statements(pth : PATH)
is_line_a_motion(line) : BOOLEAN
```

### Motion Statement Structure (`t_MOTIONSTAT`)
```
typ   : BYTE     -- MOVE_JOINT(1), MOVE_LINEAR(2), MOVE_CIRCLE(3), MOVE_ARC(4)
id    : SHORT    -- P[n] position index
speed : BYTE
term  : BYTE     -- 0=FINE, else coefficient
fine  : BOOLEAN
accel : BYTE
coord : BOOLEAN  -- coordinated motion
rtcp  : BOOLEAN  -- Robot Tool Center Point
tool_offset / frame_offset : BYTE
callback : t_MOTIONCALL   -- TA/TB timing
```

### LS File Format
Lines follow `:  <statement> ;`, header ends at `/MN`, positions at `/POS`, ends at `/END`.

### Dependencies
- `pose`, `errors`, `files`, `Strings`, `Hash`, `pathmotion`, `pathlib`, `pathmake`, `ktransw-macros`

---

## `lib/forms` / `lib/forms_`

**Purpose:** Load, display, and delete FANUC TP user-interface form dictionaries (`.ftx` files). `forms_` is an identical working copy of `forms`.

### Key API
```
forms__load(filename, dict_name) : BOOLEAN
forms__delete(dict_name) : BOOLEAN
forms__show(dict_name, value_array[])    -- displays on TP USER2 panel
```

Wraps FANUC built-ins: `DISCTRL_FORM`, `CHECK_DICT`, `REMOVE_DICT`, `FORCE_SPMENU`.

### Dependencies
- `errors`, `TPElib`, `registers`, `ktransw-macros`

---

## `lib/KUnit`

**Purpose:** Unit testing framework for Karel programs. Tests run on the controller and are accessible via HTTP from a browser.

### Test Execution
```
http://robot.ip/KAREL/kunit?filenames=test_name
http://robot.ip/KAREL/kunit?filenames=test1,test2&output=html
```

### Key API
```
kunit_test(name : STRING; result : BOOLEAN)
kunit_done

-- Assertions
kunit_assert(actual : BOOLEAN)
kunit_eq_int(expected, actual : INTEGER)
kunit_eq_r(expected, actual : REAL)
kunit_eq_rep(expected, actual, epsilon : REAL)       -- fuzzy real equality
kunit_eq_str(expected, actual : STRING)
kunit_eq_pos(expected, actual : XYZWPR)
kunit_eq_vec(expected, actual : VECTOR)
kunit_eq_vrl(expected, actual : VECTOR; epsilon : REAL)
kunit_eq_cfg(expected : STRING; actual : XYZWPR)
kunit_eq_jnt(expected, actual : JOINTPOS)

-- Arrays
kunit_eq_arr / kunit_eq_ari / kunit_eq_arv / kunit_eq_arp / kunit_eq_2d / kunit_eq_arb

-- Uninitialized checks
kunit_un_int / kunit_un_str / kunit_un_r

-- Large string comparison (> 254 chars)
k_init_pipe / k_close_pipe / kunit_pipe(s) / kunit_eq_pip(fname)
```

### Output Format
- `.` for pass, `F` for fail, line-wrapped every 40 tests
- Summary: total tests, total assertions, failure count, tests/sec, assertions/sec
- Uses semaphores for parallel task sync; writes to pipe files

### Dependencies
- `Strings`
