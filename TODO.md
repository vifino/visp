# visp todo
# Compilers
## Stage 0 (Lua Bootstrap Compiler/Runtime)
* Lua interpreter/JIT.
* Bare essentials, "just enough" compliance.
* With the JIT, should be decently performing.
* Keep up to date to prevent bloat and bitrot.

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
  - [x] Control statements
    - We got cond!
  - [ ] Global definition
    - [ ] Variables/Functions
    - [ ] Syntax
  - [ ] Local definition
    - [ ] Variables/Functions
  - [ ] Char handling
  - [ ] List handling
  - [ ] String handling
  - [ ] Comparisons
- [ ] Scheme standard library.

## Stage 1 (Lisp compiler running on Stage 0)
* Compiler emitting Lisp/Scheme code
* One frontend, multiple backends.
* Simple scheme backend:
  - helps find compiler bugs
  - runnable platform early on
  - easily testable
* Write testsuite. Run testsuite.
  - Also make it run with Stage 0?

## Stage 2 (Scheme Compiler converted on Stage 1)
* Same compiler emitting C/ASM/whatever..
  - Lots of effort.
  - Requires GC, presumably.
* Fully self-hosted.
