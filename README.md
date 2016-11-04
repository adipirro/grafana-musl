## Building for alpine/musl

Build, specifying a branch (or a tag)
```
make all BRANCH=v3.1.1
```

Building without a TAG builds the master branch
```
make all
```

Upon completion, the distribution package will be extracted from the container to the local `dist` directory.

At the time of writing this, builds take ~10-15min. Dependent on internet speed.

## What's going on?

A simple build container is created based on Alpine Linux. The build container simply runs the `build.sh` script.

**build.sh**

Should be fairly easy to parse through the script, but here is a basic overview.

1. Sets up Go environment, installs required packages, clones the grafana codebase
2. Replaces default ldflags in build.go. `-w` becomes `-w -linkmode external -extldflags '-static'`. Some more info on that [here](https://dominik.honnef.co/posts/2015/06/go-musl/)
3. Builds backend and frontend
4. Removes musl incompatible `phantomjs`. **NOTE:** Causes some features to break. Working on compiling a full list.
5. Strips binaries, removing inessential information and reducing size (that is the goal here after all)
5. Cleans up packages which are no longer needed
