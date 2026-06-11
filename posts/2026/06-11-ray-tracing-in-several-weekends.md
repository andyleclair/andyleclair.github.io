%{
  title: "Ray Tracing In Several Weekends",
  description: "Notes on building a ray tracer in Coalton",
  author: "Andy LeClair",
  tags: ["coalton", "lisp", "graphics"],
  related_listening: "https://www.youtube.com/watch?v=g9Oke7osOYE",
}
---

![some raytraced spheres](assets/images/06-11-raytracer-out.png)

As a fun project, I've been working my way through [Ray Tracing In One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html) in [Coalton](https://coalton-lang.github.io). My code for this project is available here: [source](https://tangled.org/andyleclair.dev/ray).

I have heard tell that the SBCL compiler can emit very fast code, however, it's a bit of a bear to get it to do so. I've also heard tell that Coalton aims to make that more ergonomic (and functional!) so I was interested in learning Coalton, and building a ray tracer is a great project to learn a new language. It's self-contained, doesn't really require any outside libraries, and the final output looks cool af.

Overall, this was a really fun project, and I'm glad I did it. I primarily tried to use [Mine](https://coalton-lang.github.io/mine/) for writing the code. The built-in REPL is delightful (albeit with some known warts) and it was generally intuitive to use. For the final render, however, I use SBCL directly from the command-line, because the SBCL that ships with Mine doesn't enable ALL of the optimizations (for good reason), and to get my code running as fast as possible, I really did want all the optimizations enabled. The members of the Coalton Discord were very friendly and helpful when I ran into issues or misunderstandings. It was really neat being able to inspect the compiled assembly of the functions I'd written using `(cl:disassemble)`.

Coalton's claim is that it makes getting performant code out of CL much easier, and I'd say in the general case, that's true. Typeclasses create tight, statically dispatched functions (as opposed to the generic math that CL often wants to do), however, there's still more to go. My implementation of Vector math uses a straightforward functional construction that (currently) Coalton cannot fully optimize. Consider the following:

```lisp
(coalton-toplevel
    (define-type Vec3 (Vec3 F64 F64 F64))

    (declare vec-add (Vec3 * Vec3 -> Vec3))
    (define (vec-add (Vec3 ux uy uz) (Vec3 vx vy vz))
        (Vec3 (+ ux vx) (+ uy vy) (+ uz vz)))
)
```

Note: all Coalton code is declared in a `(coalton-toplevel)` macro, since the Coalton compiler is just a VERY complex macro!

We declare our type, a `Vec3` of 3 64-bit floats (or `:double-float` in CL parlance) and a simple function to add two vectors. We destructure the two vectors and return a new vector, adding the elements together.

This style of definition, while straightforward, results in rather bogus performance in this program that's dominated by vector math. A high-quality run of my raytracer (500 samples per-pixel) multi-threaded across 12 cores (on my Ryzen 9 3900x) takes this much time (output from the excellent and convenient `(time (ray::main))` CL macro):

```
Evaluation took:
  7259.111 seconds of real time
  51874.984375 seconds of total run time (28881.281250 user, 22993.703125 system)
  [ Real times consist of 1308.861 seconds GC time, and 5950.250 seconds non-GC time. ]
  [ Run times consist of 1077.093 seconds GC time, and 50797.892 seconds non-GC time. ]
  714.62% CPU
  312 forms interpreted
  36 lambdas converted
  27,584,800,899,153 processor cycles
  27,168,611,703,856 bytes consed
```

1300 seconds, that is almost 22 _entire minutes_ of just garbage collecting! Yeesh!! Not great.

Now, an experienced CL programmer would probably say "why are you wrapping that in a structure, just return the 3 values", which, _yes_ I _could_ however, the ergonomics aren't great and you end up with libraries like [Veq](https://github.com/inconvergent/cl-veq) which, comes with its' own DSL, yadda yadda. Many would argue "that's the LISP way!" and yes, probably correct, _however_, I am of the opinion that you shouldn't have to bend over backwards to get performance. The straightforward implementation _should_ be fast!! I would expect that my implementation above worked the same as this example:

```lisp
(coalton-toplevel
    (declare vec-add (F64 * F64 * F64 * F64 * F64 * F64 -> F64 * F64 * F64))
    (define (vec-add ux uy uz vx vy vz)
        (values (+ ux vx) (+ uy vy) (+ uz vz)))
)

```

I know that using regular arguments and `values` (along with `(multiple-value-bind)` or just `(values)` in Coalton) allows the compiler to handle [dynamic extent](https://novaspec.org/cl/m_dynamic-extent) (meaning: stack allocatable-ness) but it really complicates the calling code if I must _always_ return multiple values to get the performance.

I'm interested in experimenting with an implementation based on `(cl:make-array 3 :element-type 'cl:double-float)` that would have a `vec-add` implementation looking more like this (pseudocode, untested):

```lisp
(coalton-toplevel
    (declare vec-add (Vec3 * Vec3 * Vec3 -> Void))
    (define (vec-add u v out)
        (for ((i 0) (1+ i))
            (set! out (+ (aref u i) (aref v i)))))
)
```

Representing a `Vec3` as `cl:simple-array` has the added benefit that I would be able to use [sb-simd](https://sbcl.org/manual/index.html#sb_002dsimd), however, I've tried experimenting with the library and I can't quite figure out how to make it work. The documentation seems to be incorrect and it's not straightforward to read the source since so much of the library is built on macros that delegate to platform-specific code (due to the nature of SIMD intrinsics). If you know more about `sb-simd` please reach out! I'd love for my ray tracer to be competitive with e.g. a Zig version (Zig has very good autovectorization support). I plan on writing a Zig version for essentially the same pedagogical reason: to learn me some Zig!

Coalton has an [open PR](https://github.com/coalton-lang/coalton/pull/2001) for an optimization that would make my initial implementation perform much better, as it could know that the inputs and outputs could be stack allocated, and I'll be happy to try it when (if) it lands.

I believe that SBCL currently also boxes F64s, which might really be hurting performance here. I haven't dug deeply in with a profiler, but the output of `time` shows my program using a LOT of memory, so it would stand to reason that most of why it's so slow is allocating and GC-ing.

I've got some good feedback and ideas for improving Mine and Coalton. I hope that this project will work as a useful testbed for performance improvements to Coalton!
