# GNU make: re-generate header file when git HEAD changes

Assuming you want to generate the headerfile `build/git-state.h` that reflects
the current HEAD's git SHA and also reflect if the working tree is clean or not.

The naive approach to this would be something like this:


```
test: test.c build/git-state.h
	...

# if we don't make this phony, it will only be generated once
# and so will most likely not reflect the current worktree state
.PHONY: build/git-state.h
build/git-state.h
	sh script_to_generate_header.sh

```

which has the obvious disadvantate that `test` will be rebuilt every time you
invoke make since build/git-state.h is generated every time as well.

## Broken idea of avoiding this

One idea might be to have a script that re-generates the header file only if
something actually changed:

- build a status string like "HEAD-SHA:TREE-IS-CLEAN"
- compare this string to the contents of build/last-git-state
- if they differ:
	- write status string to build/last-git-state
	- generate build/git-state.h

...make will then pick up if the modification time of `build/git-state.h` did
change or not and only rebuild `test` if that's the case, right?

Turns out, no. Once a file is nominated for re-building (due to it being out of
date or being PHONY), that state will not change during the build.

So once make decides it needs to rebuild our main target, it will not change its
mind.

Except:

## Simplest (but slightly wonky) solution

...if we put our call to the generator script into a top-level `$(shell)` call,
make will pick up our changes to the git-state.h header just fine.

This solution is implemented in [Makefile.shell](Makefile.shell) and
[update-git-state.sh](update-git-state.sh)

I'm calling this wonky because the fact that git-state.h is being generated is
not reflected inside the Makefile at all - it kind of happens behind the build
system's back.

Therefore:

## "pure" GNU make solutions

Although still relying on (unavoidable, but side-effect free) `$(shell)` calls
to call git, the two variants [Makefile.pure](Makefile.pure) and
[Makefile.eval](Makefile.eval) do contain actual rules and recipes that generate
`build/git-state.h` - even going further and generating the header file purely
with make macros and calls to the `$(file)` function.

The differences:

## Makefile.pure

Does things in a rather straight-forward manner by reading the old state, getting the current state, comparing them in top-level `ifneq` and `ifeq` directives and
uses this to force the `build/git-state.h` to be phony or not accordingly.

## Makefile.eval

Doesn't use top-level ifs. It boils down to:

```Makefile
are_same_$(git_state):=y
are_same=$(are_same_$(last_state))

.PHONY: $(if $(are_same),,build/git-state build/git-state.h)
```

Assuming `git_state=aa11bb22.dd` and `last_state=aa11bb22.dd` (both at the same HEAD and working tree is not clean) this will evaluate to:

```Makefile
# are_same_$(git_state):=y
are_same_aa11bb22.dd:=y
# are_same=$(are_same_$(last_state))
# are_same=$(are_same_aa11bb22.dd)
are_same=y

# .PHONY: $(if $(are_same),,build/git-state build/git-state.h)
# .PHONY: $(if y,,build/git-state build/git-state.h)
.PHONY: build/git-state build/git-state.h
```

Assuming `git_state=aa11bb22.dd` and `last_state=aa11bb22.cc` (both at the same HEAD, tree changed from clean to dirty);

```Makefile
# are_same_$(git_state):=y
are_same_aa11bb22.dd:=y
# are_same=$(are_same_$(last_state))
# are_same=$(are_same_aa11bb22.cc)
are_same=

# .PHONY: $(if $(are_same),,build/git-state build/git-state.h)
#.PHONY: $(if ,,build/git-state build/git-state.h)
.PHONY: 
```

## side-note: generating files without external scripts

This is often possible and sometimes advantageous, for example when working on
an OS where spawning processes is ridiculously slow.

The first thing that's needed is a "template" macro definition:

```Makefile
define git-state.h

#define GIT_SHA 0x$(git_sha)
#define GIT_SHA_STRING "$(git_sha)"
#define GIT_CLEAN 0x$(git_clean)

endef

```

- yes, `git-state.h` is a valid variable name
- yes, GNU make will expand all the text, even the '#define' lines that would
  normally be comments in a Makefile

With a recent enough version of GNU make (4.x I thinkg), you can use `$(file)`,
you can write a recipe like this:

```Makefile
build/git-state.h:
	$(info generating header file $@: $?)
	$(file >$@,$(git-state.h))
```

