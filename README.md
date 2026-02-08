# VSS-Rust

**VSS-Rust** is a high-performance bridging library designed for seamless, two-way string exchange between the **Ada** and **Rust** programming languages.

It provides a robust mechanism for sharing string data across the FFI boundary, utilizing a reference-counted handle system that ensures memory safety and stability.

## Warning - Work in Progress
TODO: Code review, check and improve Rust's handles and reference counting

**VSS-Rust is in a pre-alpha state.** Please be advised that the internal module hierarchy, type definitions, and public API are unstable and may undergo significant changes without notice.

## Key Features

- **TODO: Stable Reference Counting:** Implements a handle-based system (similar to Python's C-API) using Rust's `Arc<T>`.

- **Zero-Copy Access:** Provides direct pointers to internal UTF-8 buffers for efficient read operations in Ada.
- **Bi-directional Integration:** Designed specifically to complement the [VSS (Virtual String System)](https://github.com/AdaCore/vss-text) ecosystem.

## Requirements

### Ada Toolchain
Ensure you have **Alire** (the Ada Library Manager) and the GNAT toolchain installed.
- [Alire Installation Guide](https://alire.ada.dev)

### Rust Toolchain
The latest stable version of the Rust compiler and Cargo is required.
- [Rust Installation Guide](https://rust-lang.org)

#### Windows Specifics
*Note: The MSVC toolchain is not supported.*

For Windows users, the **GNU toolchain** is required for compatibility with the Ada GNAT/GCC compiler. 
When installing Rust via [rustup](https://rust-lang.org), ensure the `x86_64-pc-windows-gnu` target is selected and installed:

```bash
rustup toolchain install stable-x86_64-pc-windows-gnu
rustup default stable-x86_64-pc-windows-gnu
```

*Verify Toolchain (Windows)*

Before building, ensure that you are using the GNU toolchain. You can verify your active toolchain by running:

```bash
rustup show
```

The output should indicate `active toolchain: stable-x86_64-pc-windows-gnu`. If it shows `msvc`, switch to the correct one using the command:
```bash
rustup default stable-x86_64-pc-windows-gnu
```

## Building from Sources

### 1. Clone the repository
```bash
git clone https://github.com/SergeyNM/vss-rust.git
cd vss-rust
```

### 2. **Verify Toolchain Consistency**
To ensure Rust uses the same toolchain as GNAT (avoiding ABI mismatches), verify your environment via Alire:

*  **Check Rust Host (Windows/Linux):** Run `alr exec -- rustc -vV`.
      - On Windows, it must show `host: x86_64-pc-windows-gnu`.
      - On Linux, it typically shows `host: x86_64-unknown-linux-gnu`.
*  **Check GCC Path:** Run `alr exec -- which gcc`.
      - It should point to the Alire toolchain cache (e.g., `.../alire/cache/toolchains/gnat_native...`), ensuring that Alire's GCC is prioritized over the system-wide installation.

### 3. Build the Rust crate
```bash
cargo update
alr exec -- cargo build
# TODO: alr exec -- cargo build --release
```

### 4. Build the Ada components
```bash
alr update
alr build
```

TODO: Improve building.

### 5. Running Tests
The project includes a comprehensive test suite. You can open and run it using GNAT Studio:
```bash
gnatstudio -P ./gnat/tests/vss_rust_tests.gpr
```
TODO: Improve tests.

## Platform-Specific Notes (Windows)
When building under Windows (specifically for MinGW/MSYS2 toolchains), the Ada project's Linker package must include specific system libraries required by the Rust standard library and its dependencies:
```ada
package Linker is
   for Default_Switches ("Ada") use (
      --  user libraries:
      ...              
      --
      --  Windows Specific
      --  system libraries must be bellow:
      "-lwinpthread",  --  Mandatory for pthread_rwlock_* support in Rust
      "-lws2_32",      --  Required for network sockets (e.g., reqwest)
      "-luserenv",     --  Required for system profile and environment calls
      "-lntdll"        --  Required for low-level system functions
      --  "-lbcrypt"   --  Required if cryptographic/random features are enabled
   );
end Linker;
```

## License
This project is licensed under the same terms as [VSS (Virtual String System)](https://github.com/AdaCore/vss-text), ensuring compatibility with the Ada String System ecosystem.
