#!/bin/sh

OUT=build/git-state.h
STATE_FILE=build/git-state
GIT_SHA=`git rev-parse --short=8 HEAD`

[[ -z "$(git status -uno --porcelain)" ]] && GIT_CLEAN=CC || GIT_CLEAN=DD
STATE="${GIT_SHA}.${GIT_CLEAN}"
# touch once to avoid error from cat
touch ${STATE_FILE}
LAST_STATE=`cat ${STATE_FILE}`

update_files() {
	echo -n $STATE > $STATE_FILE

	cat << EOF > ${OUT}
#define GIT_SHA 0x${GIT_SHA}
#define GIT_SHA_STRING "${GIT_SHA}"
#define GIT_CLEAN 0x${GIT_CLEAN}

EOF
	echo "generated ${OUT}: $1"
	exit 0
}

[[ -f ${OUT} ]] || update_files "file did not exist"

[[ "$LAST_STATE" != "$STATE" ]] && update_files "old git state '$LAST_STATE' != '$STATE'"

echo "${OUT} up to date"
