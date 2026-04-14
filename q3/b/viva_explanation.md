# Solution Walkthrough

1. **Identifying Vulnerability:** I analyzed the binary using `objdump` and found that `main` uses `_IO_gets`. Since `gets()` has no bounds checking, I knew I could perform a buffer overflow.
2. **Finding the Rigged Logic:** I noticed that the code always branches to `.fail` right off the bat, because `_IO_gets` simply returns a pointer to the buffer (which is never `0`). Normal execution is essentially rigged to fail.
3. **Exploiting the Epilogue:** Crucially, I saw the `.fail` block does not `exit()` the program immediately. It drops down to `.end`, where the function retrieves the Return Address (`ra`) from the stack and legitimately issues a `ret`. 
4. **Calculating Stack Offset:** I tracked the Stack Pointer (`sp`). Because `main` decrements `sp` by 160 bytes for the buffer space and stores `ra` 8 bytes above that, I calculated an exact Return Address offset of 168 bytes (`160 + 8`).
5. **Crafting the Payload:** I wrote a Python script to build a 176 byte payload. It pushes 168 bytes of junk characters to overflow the stack buffer precisely down to `ra`. It overwrites `ra` with `0x104e8` (the exact memory address of the `.pass` block). Once `.fail` wraps up and triggers the `ret` instruction, my hijacked pointer seamlessly executes the win screen.
