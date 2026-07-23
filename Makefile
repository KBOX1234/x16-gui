TARGET = cx16

CC = cc65
CL = cl65
AS = ca65
AR = ar65

NAME = mylib
LIB = lib/$(NAME).a

CFLAGS = -O -Iinclude

SRC_DIR = src
EXAMPLE_DIR = examples
BUILD_DIR = build


# Find all C and assembly sources recursively
C_SOURCES = $(shell find $(SRC_DIR) -type f -name '*.c')
S_SOURCES = $(shell find $(SRC_DIR) -type f -name '*.s')


# Convert sources to build objects
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
OBJECTS += $(patsubst %.s,$(BUILD_DIR)/%.o,$(S_SOURCES))


# Find example directories only
EXAMPLES = $(shell find $(EXAMPLE_DIR) -mindepth 1 -maxdepth 1 -type d)

EXAMPLE_TARGETS = $(foreach dir,$(EXAMPLES),$(BUILD_DIR)/$(notdir $(dir))/$(notdir $(dir)).prg)


.PHONY: all clean lib examples

all: lib examples


#
# Build library
#

lib: $(LIB)

$(LIB): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(AR) r $@ $^


#
# Compile library objects
#

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -t $(TARGET) $(CFLAGS) -o $(@:.o=.s) $<
	$(AS) -t $(TARGET) $(@:.o=.s) -o $@
	@rm $(@:.o=.s)

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) -t $(TARGET) $< -o $@


#
# Build examples
#

examples: $(EXAMPLE_TARGETS)


define EXAMPLE_template

$(BUILD_DIR)/$(notdir $(1))/$(notdir $(1)).prg: $(1)/main.c $(LIB)
	@mkdir -p $$(dir $$@)
	$(CL) -t $(TARGET) -Iinclude $$< $(LIB) -o $$@

endef

$(foreach dir,$(EXAMPLES),$(eval $(call EXAMPLE_template,$(dir))))


#
# Cleanup
#

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(LIB)
