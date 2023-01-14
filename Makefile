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

