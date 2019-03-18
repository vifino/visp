# visp todo
# Compilers
## Stage 0 (Lua Bootstrap Compiler/Runtime)
* Lua interpreter/JIT.
* Bare essentials, no(t much) compliance.
* With the JIT, should be decently performing.
* Keep up to date to prevent bloat and bitrot.

- [x] Codegen library
- [x] Basic tokenizer/lexer/parser
- [x] AST formatter/dumper. Should be compilable!
- [x] Basic evaluator
- [ ] Primitives
- [ ] Builtins
  - [ ] Numbers
  - [ ] Chars
  - [ ] Lists
  - [ ] Strings
  - [ ] Comparisons
  - [ ] Control statements
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
