# dlibc

## Exit Handling

### CHERI
`_Exit` is implemented by jumping to the return capability, which is
assumed to be set before program execution begins.

### MMU
TODO

## Files

Dandelion only exposes the abstraction of "inputs" and "outputs", which
are binary blobs of data. To ease interoperability with existing code,
we also aim to support file I/O, both as specified in the C standard
library, as well as posix files. We achieve this in the following manner:

Each input and output is represented as a simple growable vector of
the following form:

```
struct buf {
    void* data;
    size_t length;
    size_t min_size;
}
```

This buffer can be written to, and the data pointer can be set explicitly,
for example to a user-allocated buffer.

To enable support for files, we additionally need to keep track of things
such as seek position, I/O mode (standard vs wide), mode, etc.
We achieve this by storing files in the following manner:

```
struct _IO_file {
    struct buf* buf;
    size_t offset;
    int mode;
}
```

This is also necessary to be able to open the same output multiple times,
and read ad different offset simultaneously.

Furthermore, to enable us to associate files with inputs and outputs,
we receive a metadata input, which contains a mapping from file paths
(relative to a virtual root directory in which the program is executing)
to input/output numbers, e.g.:

"/hello.txt" => input 0
"/x/y.txt"   => output 1
"/foo.c"     => input 1

Executing `fopen` then proceeds as follows:
1. Find input or output that requested file maps to.
2. Check that mode flags make sense (e.g. we're not trying to write
   to an input file.
3. Allocate a `struct _IO_file`, say, `file`
4. Point the `buf` member of `file` to the input/output we found
   in step 1.

All POSIX functions interacting with files are implemented on top of
`struct _IO_file`. When `open` is called, a new file descriptor is
allocated in a global table, with a corresponding instance of 
`struct _IO_file`. Any operations on the file descriptor are simply
delegated to the stdio implementation through the global table.

If `open` is called with `O_CREAT`, and there is no metadata entry
corresponding to the filename specified, the file is created as
a temporary file. We keep a separate mapping from newly created files
to file buffers. These are implicitly destroyed when the process exits.


