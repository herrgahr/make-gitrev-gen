shell:
	$(MAKE) -f Makefile.shell
pure:
	$(MAKE) -f Makefile.pure

clean:
	-rm -f build/git-state
	-rm -f build/git-state.h

