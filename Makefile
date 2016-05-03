.PHONY: build test install uninstall reinstall clean

FINDLIB_NAME=unix-unistd
MOD_NAME=unix_unistd

OCAML_LIB_DIR=$(shell ocamlc -where)

CTYPES_LIB_DIR=$(shell ocamlfind query ctypes)

LWT_LIB_DIR=$(shell ocamlfind query lwt)

OCAMLBUILD=CTYPES_LIB_DIR=$(CTYPES_LIB_DIR) \
           LWT_LIB_DIR=$(LWT_LIB_DIR)       \
           OCAML_LIB_DIR=$(OCAML_LIB_DIR)   \
             ocamlbuild -use-ocamlfind -classic-display

WITH_UNIX=$(shell ocamlfind query \
            ctypes unix unix-type-representations unix-errno.unix \
            > /dev/null 2>&1 ; echo $$?)
WITH_LWT=$(shell ocamlfind query \
            lwt ctypes unix unix-type-representations unix-errno.unix \
            > /dev/null 2>&1 ; echo $$?)

TARGETS=.cma .cmxa

PRODUCTS:=$(addprefix unistd,$(TARGETS))

ifeq ($(WITH_UNIX), 0)
PRODUCTS+=$(addprefix $(MOD_NAME),$(TARGETS)) \
          lib$(MOD_NAME)_stubs.a dll$(MOD_NAME)_stubs.so
endif

ifeq ($(WITH_LWT), 0)
PRODUCTS+=$(addprefix $(MOD_NAME)_lwt,$(TARGETS)) \
          lib$(MOD_NAME)_lwt_stubs.a dll$(MOD_NAME)_lwt_stubs.so
endif

TYPES=.mli .cmi .cmti

INSTALL:=$(addprefix unistd,$(TYPES)) \
         $(addprefix unistd,$(TARGETS))

INSTALL:=$(addprefix _build/lib/,$(INSTALL))

ifeq ($(WITH_UNIX), 0)
INSTALL_UNIX:=$(addprefix unistd_unix,$(TYPES)) \
              $(addprefix $(MOD_NAME),$(TARGETS))

INSTALL_UNIX:=$(addprefix _build/unix/,$(INSTALL_UNIX))
INSTALL_UNIX:=$(INSTALL_UNIX) \
	      -dll _build/unix/dll$(MOD_NAME)_stubs.so \
	      -nodll _build/unix/lib$(MOD_NAME)_stubs.a

INSTALL+=$(INSTALL_UNIX)
endif

ifeq ($(WITH_LWT), 0)
INSTALL_LWT:=$(addprefix unistd_unix_lwt,$(TYPES)) \
             $(addprefix $(MOD_NAME)_lwt,$(TARGETS))

INSTALL_LWT:=$(addprefix _build/lwt/,$(INSTALL_LWT))
INSTALL_LWT:=$(INSTALL_LWT) \
	      -dll _build/lwt/dll$(MOD_NAME)_lwt_stubs.so \
	      -nodll _build/lwt/lib$(MOD_NAME)_lwt_stubs.a

INSTALL+=$(INSTALL_LWT)
endif

ARCHIVES:=_build/lib/unistd.a

ifeq ($(WITH_UNIX), 0)
ARCHIVES+=_build/unix/$(MOD_NAME).a
endif

ifeq ($(WITH_LWT), 0)
ARCHIVES+=_build/lwt/$(MOD_NAME)_lwt.a
endif

build:
	$(OCAMLBUILD) $(PRODUCTS)

test: build
	$(OCAMLBUILD) unix_test/test.native
	./test.native
	$(OCAMLBUILD) lwt_test/lwt_test.native
	./lwt_test.native


install:
	ocamlfind install $(FINDLIB_NAME) META \
		$(INSTALL) \
		$(ARCHIVES)

uninstall:
	ocamlfind remove $(FINDLIB_NAME)

reinstall: uninstall install

clean:
	ocamlbuild -clean
	rm -f lib/unistd.cm? unix/unistd_unix.cm? \
	      lib/unistd.o unix/unistd_unix.o
