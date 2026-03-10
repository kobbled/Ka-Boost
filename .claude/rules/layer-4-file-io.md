# Layer 4 — File I/O & Communication

---

## `lib/files`

**Purpose:** File management and I/O abstraction with robust error checking. Underpins `csv`, `xmlib`, and `socket`.

### Access Modes
`RO` (read-only), `RW` (read-write from start), `AP` (append), `UD` (update from beginning)

### Key API
```
files__open(filename, access_typ, fl)
files__close(filename, fl)
files__create(filename, fl) : BOOLEAN      -- TRUE if newly created
files__clear(filename, fl)
files__load_on_disk(filename, overwrite)

files__check_open / check_closed / check_rw  -- validate state, handle errors
files__is_LS(filename, fl) : BOOLEAN         -- detect FANUC LS format (checks '/MN' header)

files__read_line(filename, fl) : STRING
files__read_line_ref(filename, fl, out_str) : BOOLEAN
files__read_bytes(filename, fl, buffer_size, out_str)
files__purge_bytes(filename, fl, buffer_size)
files__read_to_sarr(filename, fl, out[], break_str)
files__read_type(parse_str, split, offset, size, typ, out_struct, ...)

files__write(str, filename, fl)
files__write_line(str, filename, fl)
files__write_from_pipe(pipname, pip_fl, filename, write_fl, handle_file)
files__write_to_display(filename, fl)
```

### Error Codes (files.klt)
18 codes including `FILE_SUCCESS`, `FILE_RAM_FULL`, `FILE_UNINIT`, `FILE_MULTIPLE_ACCESS`, `CANT_READ`, `CANT_WRITE`

### Dependencies
- `errors`, `Strings`, `ktransw-macros`, `systemlib`

---

## `lib/csv`

**Purpose:** CSV file reading and writing for typed robot data (STRING, INTEGER, REAL, VECTOR, XYZWPR). Dual API: procedural and OOP class.

### Configuration Constants
```
CSV_MAX_COLUMNS = 12
CSV_CELL_LENGTH = 16
CSV_LINE_CHAR_LENGTH = 127

CARTESIAN_HEADER = 'x,y,z'
CYLINDRICAL_HEADER = 'theta,z,r'
CYLINDRICAL_SCANNING_HEADER = 'theta,r,z'
POSITION_HEADER = 'x,y,z,w,p,r'
```

### Class API (`csvclass`)

**Lifecycle**
```
new(filename, delim, header) / delete / clear / close
open / open_read / open_append / open_write
isopen / isclosed / check_read() : BOOLEAN
```

**Getters / Setters**
```
get_filename / get_line / get_fieldnames / get_maxlines
get_lines_written / get_lines_read
set_delimeter / set_fieldnames / set_maxlines
```

**Writing**
```
write_fieldnames
write_string(str)
write_row_string(row[])
write_row_val(row[])           -- REAL array
write_row_vector(row)          -- VECTOR (x,y,z)
write_row_xyzwpr(row)          -- XYZWPR (x,y,z,w,p,r)
write_to_display / write_to_file
```

**Reading**
```
read_header
read_line() : BOOLEAN          -- advances to next line
read_int(offset) : INTEGER
read_real(offset) : REAL
read_string(offset) : STRING
read_bool(offset) : BOOLEAN
read_vector(offset) : VECTOR
read_xyzwpr(offset) : XYZWPR
read_rarr / read_iarr / read_sarr (offset, size, out_arr[])
read_data(offset, typ, split)
```

### Dependencies
- `files`, `errors`, `systemlib`, `display`, `multitask`, `math`, `Strings`, `ktransw-macros`

---

## `lib/xmlib`

**Purpose:** Read XML configuration files on the FANUC controller using native `XML_SCAN` / `XML_SETVAR` / `XML_GETDATA` built-ins.

### Key API
```
xml__open_file(filename, access_typ, fl)    alias: xml__open
xml__close_file(filename, fl)               alias: xml__close

xml__get_attributes(filename, fl, tag_name, tag_indx, out_var_str)
    -- Extracts all attributes from the Nth occurrence of tag_name
    -- out_var_str format: '[program_name]variable_name'

xml__get_content(filename, fl, parent_tag, tag_indx, tag_names, out_content[])
    -- tag_names: comma-delimited child tags e.g. 'address,city,state,postal'
    -- out_content[]: receives extracted text values
```

### Limitations
- 5 attributes max per element (`ARRAY[5]`)
- Attribute names/values ≤ 32 characters
- Tag names: SMALL_TAG=16, MEDIUM_TAG=32, LARGE_TAG=64 (set via `TAG_LENGTH` macro)
- Read-only (no XML write support in stable code)
- OOP `xml_class` is incomplete skeleton

### Dependencies
- `files`, `errors`, `ktransw-macros`, `Strings`

---

## `lib/socket`

**Purpose:** TCP/IP socket messaging between the robot and external systems. Used for telemetry, remote control, and data exchange.

### Configuration
- Up to 8 servers (`S1:`–`S8:`) and 8 clients (`C1:`–`C8:`)
- Server config via `$HOSTS_CFG[n]`, client via `$HOSTC_CFG[n]` system variables
- **Requires:** FANUC controller option `R648: User Socket Message`

### Key API
```
socket__new_server() / socket__new_client()
socket__delete_server() / socket__delete_client()
socket__start(socket, file)        -- connect with auto-retry (500ms delays)
socket__stop(socket, file)
socket__check_tag()
socket__read_into_string_buffer()  -- recursive multi-packet read
socket__write_into_string_buffer()
```

### T_SOCKET Structure
```
connected : BOOLEAN
status    : INTEGER
port      : INTEGER
ip        : STRING[13]
number    : INTEGER          -- 1–8
tag       : STRING[3]        -- 'S1:' or 'C1:' format
env       : STRING[13]       -- FANUC system variable namespace
```

### Test Clients Included
Python, Go, Rust, C++ echo-test clients in `test/echo-test/`

### Dependencies
- `ktransw-macros`, `display`, `files`, `errors`
