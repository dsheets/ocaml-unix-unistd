.PHONY: build install uninstall reinstall clean

FINDLIB_NAME=unix-unistd
MOD_NAME=unix_unistd
BUILD=_build/lib

HAS_CTYPES := $(shell ocamlfind query ctypes.foreign fd-send-recv > /dev/null; echo $$?)

LWT_PATH := $(shell ocamlfind query lwt 2>/dev/null || true)

STUBS = $(BUILD)/$(MOD_NAME)_stubs.o

CFLAGS=-fPIC -Wall -Wextra -Werror

ifneq ($(HAS_CTYPES),0)
  SRC=lib/no_ctypes
  FLAGS=
  EXTRA_META+=requires = \"unix\"
else
  SRC=lib/ctypes
  FLAGS=-package ctypes.foreign,fd-send-recv
  EXTRA_META+=requires = \"unix ctypes.foreign fd-send-recv\"
  ifneq ($(LWT_PATH),)
    EXTRA_META += requires = \"lwt\"
    STUBS += $(BUILD)/$(MOD_NAME)_lwt_stubs.o
    FLAGS += -package lwt.unix
    CFLAGS += -I $(LWT_PATH)
  endif
endif

build: $(STUBS) $(BUILD)/$(MOD_NAME).cmi
	mkdir -p $(BUILD)
	ocamlfind ocamlmklib -o $(BUILD)/$(MOD_NAME) \
		-ocamlc "ocamlc -g" -ocamlopt "ocamlopt -g" -I $(BUILD) \
		$(FLAGS) lib/$(MOD_NAME)_common.ml $(SRC)/$(MOD_NAME).ml \
		$(BUILD)/$(MOD_NAME)_stubs.o

$(BUILD)/$(MOD_NAME).cmi: $(SRC)/$(MOD_NAME).mli $(BUILD)/$(MOD_NAME)_common.cmi
	@mkdir -p $(BUILD)
	ocamlfind ocamlc -o $@ -g -I $(BUILD) -I lib $(FLAGS) -c $<

$(BUILD)/$(MOD_NAME)_common.cmi: lib/$(MOD_NAME)_common.mli
	@mkdir -p $(BUILD)
	ocamlfind ocamlc -o $@ -g -c $<

$(BUILD)/%_stubs.o: lib/%_stubs.c
	@mkdir -p $(BUILD)
	cc -c $(CFLAGS) -o $@ $< -I$(shell ocamlc -where)

META: META.in
	cp META.in META
	echo $(EXTRA_META) >> META

install: META
	ocamlfind install $(FINDLIB_NAME) META \
		$(SRC)/$(MOD_NAME).mli \
		$(BUILD)/$(MOD_NAME).cmi \
		$(BUILD)/$(MOD_NAME).cma \
		$(BUILD)/$(MOD_NAME).cmxa \
		-dll $(BUILD)/dll$(MOD_NAME).so \
		-nodll $(BUILD)/lib$(MOD_NAME).a $(BUILD)/$(MOD_NAME).a

uninstall:
	ocamlfind remove $(FINDLIB_NAME)

reinstall: uninstall install

clean:
	rm -rf _build
	bash -c "rm -f lib/$(MOD_NAME)_common.{cm?,o} META"
	bash -c "rm -f lib/{ctypes,no_ctypes}/$(MOD_NAME).{cm?,o}"
