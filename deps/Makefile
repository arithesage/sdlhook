# ========================================================================
# Makefile orienteed to build a bunch of libraries
# ========================================================================

# ==================== CONFIG ============================================
LIBS							:=
CFLAGS							:=
CXXFLAGS						:=
LDFLAGS							:=

C_SRCS							:=

# Example:
#
# CPP_SRCS						:= ANSI/ANSI.cpp
# CPP_SRCS						+= Log/Log.cpp
CPP_SRCS						:= 

INCLUDE							:= .


# =================== INTERNALS ==========================================
ifneq (${WINDIR},)
	SYSTEM						:= windows
else
	UNAME						:= $(shell uname)

	ifeq (${UNAME},Darwin)
		SYSTEM					:= macos
	else ifeq (${UNAME},Linux)
		SYSTEM					:= linux
	else
		SYSTEM					:= other
	endif
endif

OBJ								:= obj
OBJS_PATH						:= ${OBJ}/${SYSTEM}

SRCS							:= $(strip ${C_SRCS} ${CPP_SRCS})

HEADER_PATHS					:= $(sort $(foreach file,${C_SRCS},$(dir ${file})))
HEADER_PATHS					+= $(sort $(foreach file,${CPP_SRCS},$(dir ${file})))
HEADER_PATHS					+= $(sort $(foreach file,${INCLUDE},$(dir ${file})))

INCLUDE							:= $(strip $(foreach inc,${HEADER_PATHS},-I ${inc}))
LIBS							:= $(foreach lib,${LIBS},-l${lib})

C								:= clang
CXX								:= clang++

GLOBAL_FLAGS					:= -Wall -pedantic

CFLAGS							+= ${GLOBAL_FLAGS}
CXXFLAGS						+= ${GLOBAL_FLAGS}

ifdef RELEASE
	CFLAGS						+= -O3
	CXXFLAGS					+= -O3
else
	CFLAGS						+= -g
	CXXFLAGS					+= -g
endif

include Commands.mk
include Functions.mk


# ================ OBJS PATHS GEN ========================================
OBJS							:= $(foreach src,${SRCS},$(call SRC2OBJ,${src}))


# ================ BUILD RECIPES =========================================
.PHONY: all clean info

all: ${OBJS_PATH} ${OBJS}


clean:
	$(shell ${RMTREE} ${OBJ})


${OBJS_PATH}:
	$(shell ${MKTREE} ${OBJS_PATH})


# Builds all CPP files. Each obj file will be placed under ${OBJS_PATH}
$(foreach src,${C_SRCS},$(eval $(call BUILD_C,${src})))


# Builds all CPP files. Each obj file will be placed under ${OBJS_PATH}
$(foreach src,${CPP_SRCS},$(eval $(call BUILD_CPP,${src})))


info:
	$(info CFLAGS: ${CFLAGS})
	$(info CXXFLAGS: ${CXXFLAGS})
	$(info LDFLAGS: ${CXXFLAGS})
	$(info OBJS: ${OBJS})
	$(info C_SRCS: ${C_SRCS})
	$(info CPP_SRCS: ${CPP_SRCS})
	$(info INCLUDE: ${INCLUDE})
	$(info LIBS: ${LIBS})

