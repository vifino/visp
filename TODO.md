# visp todo
# Compilers
## Stage 0 (Lua Bootstrap Compiler/Runtime)
* Lua interpreter/JIT.
  - JIT to Lua code has many benefits:
    - "Free" GC, scoping, type system...
    - High performance interpreter with PUC Lua.
    - High performance JIT available with LuaJIT.
* Bare essentials, "just enough" compliance.
  - We don't need to handle every case perfectly.
  - Should suffice for stage 1.
* Keep up to date to prevent bloat and bitrot.
  - We have a testsuite which covers 90+%. TDD.
  - Has rather simple code, considering what it does.
  - Should stay rather well commented. No dark magic.

- [x] Codegen library
- [x] Basic tokenizer/lexer/parser
- [x] AST formatter/dumper. Should be compilable!
- [x] Basic evaluator
- [ ] Primitives
  - [x] Numbers
  - [x] Booleans
  - [x] IDs/references
  - [ ] Lists
    - This is really important.
  - [?] Strings
- [ ] Builtins
  - [x] Including files
    - This is really important.
  - [x] Operatives
    - `oper`, `wrapoper`, `defoper`
      - Enough to define lambda.
  - [x] Control statements
    - We got cond!
  - [x] Comparisons
  - [ ] Global definition
    - [ ] Variables/Functions
    - [ ] Syntax
  - [ ] Local definition
    - [ ] Variables/Functions
  - [ ] Char handling
  - [ ] List handling
  - [ ] String handling
  - [x] Testing
- [ ] Standard library.
  - Should use our primitives to provide us everything else.

## Stage 1 (Lisp compiler running on Stage 0)
* Compiler in visp-flavoured Lisp, compiling visp-flavoured Lisp.
* Many challenges:
  - Need to have a sufficiently powerful stage 0.
  - Needs to handle
* One frontend, multiple backends.
  - [ ] Simple scheme backend:
    - helps find high level compiler bugs
    - runnable platform early on
    - easily implemented
  - [ ] [Mu MicroVM](https://microvm.github.io/) backend
    - Doesn't seem mature, but it brings GC and concurrency.
    - Takes care of optimizing our output. (Saves us effort.)
  - [ ] LLVM:
    - More of a long-term goal.
    - This will probably be very hard.
    - Would give us extensive optimizations.
      - Less need for us to have great optimization passes.
* Runs stdlib tests

## Stage 2 (Scheme Compiler converted on Stage 1)
* Same compiler running on the emitted code of itself.
  - Lots of effort.
* Fully self-hosted.
  - Ultimate "this actually works" test.
