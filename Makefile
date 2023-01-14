default:
	$(info $(help))

GNUMAKEFLAGS=--no-print-directory
shell:
	$(MAKE) -f Makefile.shell
pure:
	$(MAKE) -f Makefile.pure

eval:
	$(MAKE) -f Makefile.eval

clean:
	-rm -f build/git-state
	-rm -f build/git-state.h


define help
provide one of shell, pure, eval or clean as make target

  make shell             demonstrates the simple solution
  make pure              demonstrates pure-make variant 1
  make eval              demonstrates pure-make variant 2
  make clean             does the obvious thing

endef
