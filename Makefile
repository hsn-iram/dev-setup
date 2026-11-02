# Pick what to install. Nothing installs unless you name it. Run `make` for the list.
# The steps come from install.sh, so a new folder in software/ shows up here too.

STEPS := $(shell ./install.sh --list)

on = $(filter true 1 yes,$(1))
DRY := $(or $(call on,$(dry-run)),$(filter dry-run,$(MAKECMDGOALS)))
FLAGS := $(if $(DRY),--dry-run) \
         $(if $(call on,$(yes)),--yes) \
         $(if $(claude-via),--claude-via $(claude-via))

.DEFAULT_GOAL := help
.PHONY: help install update approved test dry-run $(STEPS)

help:
	@./install.sh --help

# All named steps go to one install.sh run, so they run in dependency order.
$(STEPS):
	@$(if $(filter $@,$(firstword $(filter $(STEPS),$(MAKECMDGOALS)))),./install.sh $(FLAGS) $(filter $(STEPS),$(MAKECMDGOALS)),:)

install:
	@./install.sh --approved $(FLAGS)

# Pull first, then install with the freshly pulled Makefile and scripts.
update:
	@$(if $(DRY),echo "[dry-run] git pull --ff-only",git pull --ff-only)
	@$(MAKE) --no-print-directory install $(if $(DRY),dry-run=true)

approved:
	@./install.sh --init-approved

test:
	@tests/run.sh

dry-run:
	@:
