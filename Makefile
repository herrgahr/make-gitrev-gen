test: test.c build/git-state.h
	gcc -o $@ $< -I.

$(info $(shell sh update-git-state.sh))

