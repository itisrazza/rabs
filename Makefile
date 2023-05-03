
PROJECT_NAME := rabs

BLOCK_SIZE := 1024
SCRIPT_BLOCKS := 3

default: dist/$(PROJECT_NAME)-install

dist/$(PROJECT_NAME)-install: dist dist/$(PROJECT_NAME).tar.bz2
	cat $(PROJECT_NAME)/stage0.sh | sed "s/@BLOCK_SIZE@/$(BLOCK_SIZE)/" | sed "s/@SCRIPT_BLOCKS@/$(SCRIPT_BLOCKS)/" | dd of="$@" bs=$(BLOCK_SIZE)
	dd if=dist/$(PROJECT_NAME).tar.bz2 of="$@" bs=$(BLOCK_SIZE) seek=$(SCRIPT_BLOCKS)
	chmod a+x "$@"

dist/$(PROJECT_NAME).tar.bz2: $(wildcard $(PROJECT_NAME)/*)
	tar cf "$@" $(PROJECT_NAME)

#

dist:
	mkdir -p "$@"

#

.PHONY: clean
clean:
	rm -rf dist
