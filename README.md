# docker-makefile

GNU Makefile to simplify docker image builds. Supports buildx

## Quickstart

1. Create `.makerc`

```
cat << EOF > .makerc
IMG_VERSION = 1.0.0
IMG_REPOSITORY = helloworld
EOF
```

2. Build Image

```
make
```

*Note:* The `.makerc` will automatically be read

3. Push Image

```
make push
```

## Troubleshooting

1. When in doubt append Make option `--dry-run`. 
