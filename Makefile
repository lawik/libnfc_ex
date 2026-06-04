# SPDX-License-Identifier: Apache-2.0
#
# Builds the libnfc_nif NIF with a vendored, statically-linked libnfc
# (PN532 I2C driver only). Designed to cross-compile for Nerves via
# elixir_make.
#
# Makefile targets:
#
# all:    build and install the NIF into $(MIX_APP_PATH)/priv
# clean:  clean build products
#
# Variables to override (all provided by elixir_make / Nerves):
#
# MIX_APP_PATH      path to the build directory
# ERTS_INCLUDE_DIR  erts include directory (set by Nerves for the target)
# CC                C compiler
# CROSSCOMPILE      crosscompiler prefix, set when building for Nerves targets

PREFIX = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj

NIF = $(PREFIX)/libnfc_nif.so

LIBNFC_DIR = c_src/libnfc

CFLAGS ?= -g -O2
CFLAGS += -std=c11 -fPIC -Wall -Wextra -Wno-unused-parameter

# Feature-test macros for POSIX APIs (clock_gettime, nanosleep, usleep)
# that -std=c11 would otherwise hide. Autoconf normally does this.
CFLAGS += -D_GNU_SOURCE

# config.h (ours) + vendored libnfc headers
CFLAGS += -Ic_src -DHAVE_CONFIG_H
CFLAGS += -I$(LIBNFC_DIR)/include -I$(LIBNFC_DIR)/libnfc

ERTS_INCLUDE_DIR ?= $(shell erl -noshell -eval "io:format(\"~ts/erts-~ts/include/\", [code:root_dir(), erlang:system_info(version)])" -s init stop)
ERL_CFLAGS ?= -I$(ERTS_INCLUDE_DIR)

LDFLAGS += -shared

ifeq ($(CROSSCOMPILE),)
    # Host build: the PN532 I2C driver needs Linux I2C headers, so the
    # NIF can only be built on Linux hosts. On other platforms (e.g.
    # macOS) nothing is built and LibNFC.Mock can be used instead.
    ifneq ($(shell uname -s),Linux)
        NIF =
    endif
else
    # Nerves crosscompile (always Linux targets)
    LDFLAGS += -Wl,--no-as-needed
endif

LIBNFC_SRC = \
	$(LIBNFC_DIR)/libnfc/nfc.c \
	$(LIBNFC_DIR)/libnfc/nfc-device.c \
	$(LIBNFC_DIR)/libnfc/nfc-internal.c \
	$(LIBNFC_DIR)/libnfc/conf.c \
	$(LIBNFC_DIR)/libnfc/iso14443-subr.c \
	$(LIBNFC_DIR)/libnfc/mirror-subr.c \
	$(LIBNFC_DIR)/libnfc/target-subr.c \
	$(LIBNFC_DIR)/libnfc/log.c \
	$(LIBNFC_DIR)/libnfc/log-internal.c \
	$(LIBNFC_DIR)/libnfc/chips/pn53x.c \
	$(LIBNFC_DIR)/libnfc/drivers/pn532_i2c.c \
	$(LIBNFC_DIR)/libnfc/buses/i2c.c

SRC = src/libnfc_nif.c $(LIBNFC_SRC)
OBJ = $(SRC:%.c=$(BUILD)/%.o)

calling_from_make:
	mix compile

all: install

install: $(PREFIX) $(BUILD) $(NIF)

$(OBJ): Makefile c_src/config.h

$(BUILD)/%.o: %.c
	@echo " CC $(notdir $@)"
	@mkdir -p $(dir $@)
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(NIF): $(OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(LDFLAGS) $^

$(PREFIX) $(BUILD):
	mkdir -p $@

check:
	cppcheck --enable=all --library=posix --suppress=missingIncludeSystem src/libnfc_nif.c

clean:
	$(RM) -r $(BUILD)/src $(BUILD)/c_src $(NIF)

.PHONY: all clean calling_from_make install check

# Don't echo commands unless the caller exports "V=1"
ifneq ($(V),1)
.SILENT:
endif
