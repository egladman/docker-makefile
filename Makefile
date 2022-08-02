-include .makerc

DOCKER := docker
GIT := git

CHAR_SPACE=$() $()
CHAR_COMMA=,

# Automatically use Docker buildx plugin when found
BUILDX_ENABLED := $(shell $(DOCKER) buildx version > /dev/null 2>&1 && printf true || printf false)
LATEST_ENABLED ?= true

IMG_VARIANT := core
GIT_SHORT_HASH := $(shell $(GIT) rev-parse --short HEAD || printf undefined)

IMG_TAGS := $(IMG_VERSION) \
            v$(IMG_VERSION) \
            git-$(GIT_SHORT_HASH)

ifndef IMG_VERSION
    $(error IMG_VERSION is not set)
endif

ifndef IMG_REPOSITORY
    $(error IMG_REPOSITORY is not set)
endif

ifeq ($(LATEST_ENABLED),true)
    override IMG_TAGS += latest
endif

# Image specific build args
override DOCKER_BUILD_FLAGS += --build-arg JQ_VERSION=$(IMG_VERSION) \
                               --build-arg VARIANT=$(IMG_VARIANT)

DOCKER_BUILDX_PLATFORMS := linux/amd64 \
                           linux/arm64

ifneq ($(IMG_VARIANT), core)
    override IMG_TAGS := $(addsuffix -$(IMG_VARIANT),$(IMG_TAGS))
endif

ifdef IMG_REPOSITORY_PREFIX
    override IMG_REPOSITORY := $(IMG_REPOSITORY_PREFIX)/$(IMG_REPOSITORY)
endif

# Construct '--tag <value>' docker build argument
ifdef IMG_TAGS
    IMG_NAMES := $(foreach t,$(IMG_TAGS),$(IMG_REPOSITORY):$(t))
    s := --tag
    override DOCKER_BUILD_FLAGS += $(s)$(CHAR_SPACE)$(subst $(CHAR_SPACE),$(CHAR_SPACE)$(s)$(CHAR_SPACE),$(strip $(IMG_NAMES)))
endif

# Construct '--platform <value>,<value>' buildx argument
ifeq ($(BUILDX_ENABLED),true)
    override DOCKER := $(DOCKER) buildx $(DOCKER_BUILDX_FLAGS)
    override DOCKER_BUILD_FLAGS += --platform $(subst $(CHAR_SPACE),$(CHAR_COMMA),$(DOCKER_BUILDX_PLATFORMS))
endif

.PHONY: build push
.DEFAULT_GOAL := build

build:
	$(DOCKER) build . $(DOCKER_BUILD_FLAGS)

push:
ifeq ($(BUILDX_ENABLED),true)
	$(MAKE) DOCKER_BUILD_FLAGS+="--push"
else
	$(DOCKER) push $(IMG_REPOSITORY) $(IMG_NAMES)
endif
