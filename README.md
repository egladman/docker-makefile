# docker-makefile

GNU Makefile to simplify docker image builds. Supports buildx

## Quickstart

1. Create `.makerc`

```
cat << EOF > .makerc
IMG_VERSION = 1.0.0
IMG_REPOSITORY = helloworld
IMG REPOSITORY_PREFIX = foo
EOF
```

2. Build Image

```
make
```

The following images will be built as a result.

```
foo/helloworld:1.0.0
foo/helloworld:v1.0.0
foo/helloworld:1.0.0-git-838acf9
foo/helloworld:v1.0.0-git-838acf9
foo/helloworld:latest
```

3. Push Image

```
make push
```

## Troubleshooting

1. When in doubt append Make option `--dry-run`. 
