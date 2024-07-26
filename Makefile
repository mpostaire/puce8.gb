SDIR:=src
ODIR:=out
IDIR:=inc
BIN:=puce8.gb

# recursive wildcard that goes into all subdirectories
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC:=$(call rwildcard,$(SDIR),*.s)
OBJ:=$(SRC:$(SDIR)/%.s=$(ODIR)/%.o)

HEADERS:=$(call rwildcard,$(IDIR),*.inc)
HEADERS:=$(HEADERS:$(IDIR)/%=$(ODIR)/%)
# ODIR and its subdirectories structure to mkdir if they don't exist
ODIR_STRUCTURE:=$(sort $(foreach d,$(OBJ) $(HEADERS),$(subst /$(lastword $(subst /, ,$d)),,$d)))

all: $(ODIR_STRUCTURE) $(BIN)

$(BIN): $(OBJ)
	rgblink -o $@ -n $(ODIR)/$(BIN).sym $^
	rgbfix -vp 0xFF $@ -t "puce8.gb"

$(ODIR)/%.o: $(SDIR)/%.s
	rgbasm -Weverything -o $@ $^

$(ODIR_STRUCTURE):
	mkdir -p $@

clean:
	rm -rf $(ODIR)

cleaner: clean
	rm -f $(BIN)

.PHONY: all clean cleaner
