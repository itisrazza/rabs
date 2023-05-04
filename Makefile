BLOCK_SIZE := 1024
SCRIPT_BLOCKS := 3

default: dist/rabs-install

dist/rabs-install: dist dist/rabs.tar.bz2
	cat rabs/stage0.sh | sed "s/@BLOCK_SIZE@/$(BLOCK_SIZE)/" | sed "s/@SCRIPT_BLOCKS@/$(SCRIPT_BLOCKS)/" | dd of="$@" bs=$(BLOCK_SIZE)
	dd if=dist/rabs.tar.bz2 of="$@" bs=$(BLOCK_SIZE) seek=$(SCRIPT_BLOCKS)
	chmod a+x "$@"

dist/rabs.tar.bz2: $(wildcard rabs/*)
	tar cf "$@" rabs

#

site/dist: dist/rabs-install
	cd site && npm run build
	cp dist/rabs-install site/dist/rabs-install

#

dist:
	mkdir -p "$@"

#

.PHONY: clean
clean:
	rm -rf dist
	rm -rf site/dist site/.parcel-cache
