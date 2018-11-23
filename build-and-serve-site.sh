#!/bin/bash

if [ -z "$JEKYLL_ENV" ]; then
	export JEKYLL_ENV=staging
fi
export JEKYLL_CONFIG="_config.yml,_config-$JEKYLL_ENV.yml"
export JEKYLL_ACTION="serve"

# If GEM_HOME is set, see if we need to handle it being outside
# of the current directory.
if [ ! -z "$GEM_HOME" ]; then
        gem_parent_dir="$(dirname "$GEM_HOME")"
        if [ "$gem_parent_dir" != "$(pwd)" ]; then
                # Build a volume mount command
                # and change the value for GEM_HOME to point to it
                GEM_VAR="-eGEM_HOME=/gems"
                GEM_MOUNT="-v$GEM_HOME:/gems"
        fi
else
        GEM_VAR=""
        GEM_MOUNT=""
fi

if [ -z "$DEST_DIR" ] && [ ! -d "$(pwd)/dest_dir" ]; then
	mkdir "$(pwd)/dest_dir"
fi 

docker run --rm -it -e JEKYLL_ACTION -e JEKYLL_CONFIG -e JEKYLL_ENV -e SOURCE_DIR -e DEST_DIR "$GEM_VAR" \
	"$GEM_MOUNT" -v "$(pwd)":/srv linaroits/jekyllsitebuild:latest build-site.sh
