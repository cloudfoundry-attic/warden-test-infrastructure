# Basic GNU Makefile

BUILDER_TYPES = vmware virtualbox
TEMPLATE_FILES := $(wildcard *.json)
BOX_FILENAMES := $(TEMPLATE_FILES:.json=.box)
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), $(builder)/$(box_filename)))

.PHONY: all
all: $(BOX_FILES)

# Build the box into a directory named after the provider
vmware/%.box: %.json
	rm -rf $(@D)/output
	packer build -only=$(@D) $<

# Build the box into a directory named after the provider
virtualbox/%.box: %.json
	rm -rf $(@D)/output
	packer build -only=$(@D) $<

# List the box targets
.PHONY: list
list:
	@echo $(BOX_FILES)

# Cleanup the previously created boxes
.PHONY: clean
clean:
	$(foreach builder_type,$(BUILDER_TYPES),rm -rf $(builder_type)/*;)
