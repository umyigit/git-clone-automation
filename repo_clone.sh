#!/usr/bin/env bash

normalize_git_url() {
	local url="$1"
	
	if [[ "$url" == git@github.com:* ]]; then
		url="${url#git@github.com:}"
	else
		url="${url#https://github.com/}"
		url="${url#http://github.com/}"
	fi
	
	echo "$url"
}

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <URL> <BRANCH_OR_TAG> <CLONE_PATH>"
	exit 1
fi

URL="$1"
REF="$2"
CLONE_PATH="$3"
PARENT_DIR=$(dirname "$CLONE_PATH")

mkdir -p "$PARENT_DIR" || {
	echo "Error: Failed to create parent directory."
	exit 1
}

echo
echo "Repository URL: $URL"
echo "Branch / Tag  : $REF"
echo "Clone Path    : $CLONE_PATH"
echo "Parent Dir    : $PARENT_DIR"
echo

if [ -d "$CLONE_PATH/.git" ]; then
	CURRENT_URL=$(git -C "$CLONE_PATH" remote get-url origin)

	EXPECTED_REPO=$(normalize_git_url "$URL")
	CURRENT_REPO=$(normalize_git_url "$CURRENT_URL")

	if [ "$EXPECTED_REPO" != "$CURRENT_REPO" ]; then
		echo "Error: Different repositories."
		echo "Expected: $EXPECTED_REPO"
		echo "Found: $CURRENT_REPO"
		exit 1
	fi

	echo "Expected Repo: $EXPECTED_REPO"
	echo "Current Repo: $CURRENT_REPO"

	echo "Repository is already cloned."
	echo
	
	cd "$CLONE_PATH" || exit 1
	git fetch --all --tags --prune || {
		echo "Error: Failed to fetch repository."
		exit 1
	}
	#git -C "$CLONE_PATH" fetch --all --tags --prune
else
	if [ -d "$CLONE_PATH" ]; then
		echo "Error: '$CLONE_PATH' exists but is not a Git repository."
		exit 1
	fi
	
	echo "Repository is not cloned yet."
	echo "Cloning repository..."
	
	git clone "$URL" "$CLONE_PATH" || {
		echo "Error: Failed to clone repository."
		exit 1
	}
	
	cd "$CLONE_PATH" || exit 1
fi

if git show-ref --verify --quiet "refs/remotes/origin/$REF"; then # remote branch check
	echo "$REF is a branch."
	
	if git show-ref --verify --quiet "refs/heads/$REF"; then #local branch check
		git checkout "$REF" || {
			echo "Error: Failed to checkout reference."
			exit 1
		}
	else
		git checkout -b "$REF" "origin/$REF" || {
			echo "Error: Failed to create or switch to branch."
			exit 1
		}
	fi

	git merge --ff-only "origin/$REF" || {
		echo "Error: Failed to fast-forward local branch."
		exit 1
	}

elif git show-ref --verify --quiet "refs/tags/$REF"; then
	echo "$REF is a tag."
	
	git checkout "refs/tags/$REF" || {
		echo "Error: Failed to checkout tag."
		exit 1
	}		
else
	echo "Error: '$REF' does not exist."
	exit 1
fi

git submodule update --init --recursive || {
	echo "Error: Failed to update submodules."
	exit 1
}

echo

if git symbolic-ref --quiet --short HEAD >/dev/null; then
	CURRENT_REF=$(git symbolic-ref --short HEAD)
else
	CURRENT_REF="DETACHED HEAD at $(git rev-parse --short HEAD)"
fi

LATEST_COMMIT=$(git rev-parse HEAD)
LATEST_MESSAGE=$(git log -1 --format=%B)

echo "Current REF      : $CURRENT_REF"
echo "Latest Commit    : $LATEST_COMMIT"
echo "Latest Message   : $LATEST_MESSAGE"
echo
echo "Repository Status:"
echo "------------------"
git status
echo

#show-ref -> Check whether this ref exists
#rev-parse -> Resolve this name to the commit it points to
#symbolic-ref -> Show which branch HEAD currently points to




