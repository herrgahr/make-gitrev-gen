#include <stdint.h>
#include <stdio.h>
#include "build/git-state.h"


int main() {
	printf("git rev %s\n", GIT_SHA_STRING);
	printf("git clean: %s\n", (GIT_CLEAN == 0xCC) ? "yes" : "no");
}

