
PY_DASHBOARD_DIR := ./dashboards
JSON_DASHBOARD_DIR ?= ./out

PY_DASHBOARDS := $(wildcard $(PY_DASHBOARD_DIR)/*.py)
JSON_DASHBOARDS := $(patsubst $(PY_DASHBOARD_DIR)/%.py,$(JSON_DASHBOARD_DIR)/%.json,$(PY_DASHBOARDS))

DOCKER := docker
DOCKER_REGISTRY ?= docker.io
DOCKER_REPOSITORY ?= atopuzov
DOCKER_IMAGE_TAG_BASE := $(DOCKER_REGISTRY)/$(DOCKER_REPOSITORY)/grafanalib
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_TAG_BASE):latest

USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

GENERATE_DASHBOARD ?= generate-dashboard

.PHONY: default
default: all;

.PHONY: all
all: $(JSON_DASHBOARDS);

.PRECIOUS: $(JSON_DASHBOARD_DIR)
$(JSON_DASHBOARD_DIR):
	mkdir -p $(JSON_DASHBOARD_DIR)

$(JSON_DASHBOARD_DIR)/%.json: $(PY_DASHBOARD_DIR)/%.py $(JSON_DASHBOARD_DIR)
	${GENERATE_DASHBOARD} -o $(@) $(<)

.PHONY: docker_image
docker_image:
	$(DOCKER) build \
		-t $(DOCKER_IMAGE_TAG) \
		./docker

.PHONY: docker_push
docker_push:
	$(DOCKER) push \
		$(DOCKER_IMAGE_TAG)

.PHONY: docker_pull
docker_pull:
	$(DOCKER) pull \
		$(DOCKER_IMAGE_TAG)


.PHONY: docker-%
docker-%:
	$(DOCKER) run \
		--rm \
		--volume $(PWD):/code \
		--env USER_ID=$(USER_ID) \
		--env GROUP_ID=$(GROUP_ID) \
		$(DOCKER_IMAGE_TAG) \
		make $*

VIRTUALENV_DIR ?= .env
VIRTUALENV_BIN = $(VIRTUALENV_DIR)/bin
VIRTUALENV_UPTODATE = $(VIRTUALENV_DIR)/.virtualenv-uptodate

VIRTUALENV_CMD ?= virtualenv
PIP_CMD ?= pip

VIRTUALENV := $(shell command -v $(VIRTUALENV_CMD) 2> /dev/null)
PIP := $(shell command -v $(PIP_CMD) 2> /dev/null)

$(VIRTUALENV_BIN)/pip: .ensure-virtualenv
	$(VIRTUALENV_CMD) $(VIRTUALENV_DIR)

$(VIRTUALENV_UPTODATE): $(VIRTUALENV_BIN)/pip docker/requirements.txt
	$(VIRTUALENV_BIN)/pip install \
		-r docker/requirements.txt
	touch $(VIRTUALENV_UPTODATE)

.ensure-virtualenv: .ensure-pip
ifndef VIRTUALENV
	$(error "virtualenv is not installed. Install with `pip install [--user] virtualenv`.")
endif
	touch .ensure-virtualenv

.ensure-pip:
ifndef PIP
	$(error "pip is not installed. Install with `python -m [--user] pip`.")
endif
	touch .ensure-pip

.PHONY: venv-%
venv-%: $(VIRTUALENV_UPTODATE)
	GENERATE_DASHBOARD=$(VIRTUALENV_BIN)/generate-dashboard make $*
