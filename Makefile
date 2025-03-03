# ========================================================================
# Makefile orienteed to build a library (dynamic or static)
# ========================================================================

# =================== INTERNALS ==========================================
include Project.mk


ifneq (${WINDIR},)
	LIB							:= ${PROJECT_NAME}.dll
	SYSTEM						:= windows
else
	LIB							:= ${PROJECT_NAME}.so
	UNAME						:= $(shell uname)

	ifeq (${UNAME},Darwin)
		SYSTEM					:= macos
	else ifeq (${UNAME},Linux)
		SYSTEM					:= linux
	else
		SYSTEM					:= other
	endif
endif

SRC								:= src
DEPS							:= deps
BUILD							:= build
OBJ								:= obj

OBJS_PATH						:= ${OBJ}/${SYSTEM}
DEPS_OBJS_PATH					:= $(DEPS)/${OBJ}/${SYSTEM}
BUILD_PATH						:= ${BUILD}/${SYSTEM}

LIB								:= ${BUILD}/${SYSTEM}/${LIB}


include Commands.mk
include Functions.mk


MAIN							:= ${SRC}/${MAIN}
MAIN_FILE						:= $(notdir ${MAIN})
MAIN_OBJ						:= ${OBJS_PATH}/$(call SRC2OBJ,${MAIN_FILE})

C_SRCS							:= $(shell find ${SRC}/** -type f -name "*.c" -not -name ${MAIN_FILE})
CPP_SRCS						:= $(shell find ${SRC}/** -type f -name "*.cpp" -not -name ${MAIN_FILE})

C_HEADERS						:= $(shell find ${SRC}/** -type f -name "*.h")
CPP_HEADERS						:= $(shell find ${SRC}/** -type f -name "*.hpp")

SRCS							:= $(strip ${C_SRCS} ${CPP_SRCS})
HEADERS							:= $(strip $(C_HEADERS) ${CPP_HEADERS})
OBJS							:= $(foreach src,${SRCS},$(call SRC2OBJ,${src}))

INCLUDE_PATHS					:= $(sort $(foreach file,${HEADERS},$(dir ${file})))

INCLUDE							:= $(strip $(foreach inc,${INCLUDE_PATHS},-I ${inc}))
LIBS							:= $(foreach lib,${LIBS},-l${lib})

DEPS_C_SRCS						:= $(shell find deps/* -type f -name "*.c")
DEPS_CPP_SRCS					:= $(shell find deps/* -type f -name "*.cpp")
DEPS_SRCS						:= $(strip ${DEPS_C_SRCS} ${DEPS_CPP_SRCS})
DEPS_HEADERS					:= $(shell find deps/* -type f -name "*.hpp")
DEPS_INCLUDE_PATHS				:= $(sort $(foreach file,${DEPS_HEADERS},$(dir ${file})))
DEPS_INCLUDE					:= $(strip $(foreach inc,${DEPS_INCLUDE_PATHS},-I ${inc}))
DEPS_OBJS						:= $(foreach src,${DEPS_SRCS},${DEPS_OBJS_PATH}/$(notdir $(subst .c,.o,$(subst .cpp,.o,${src}))))

C								:= clang
CXX								:= clang++

GLOBAL_FLAGS					:= -Wall -pedantic
GLOBAL_LDFLAGS					:= 

ifdef DYNAMIC_LIB
	GLOBAL_FLAGS				+= -fPIC
	GLOBAL_LDFLAGS				+= -shared
	LIBS						+= -ldl
endif

CFLAGS							+= ${GLOBAL_FLAGS}
CXXFLAGS						+= ${GLOBAL_FLAGS}

ifdef RELEASE
	CFLAGS						+= -O3
	CXXFLAGS					+= -O3
else
	CFLAGS						+= -g
	CXXFLAGS					+= -g
endif

LDFLAGS							+= ${GLOBAL_LDFLAGS}




.PHONY: all cleandeps deps clean info


all: ${OBJS_PATH} ${BUILD_PATH} ${LIB}


clean:
	$(shell ${RMTREE} ${OBJ})
	$(shell ${RMTREE} ${BUILD})


cleandeps:
	${MAKE} -C ${DEPS} clean


deps:
	${MAKE} -C ${DEPS}


${BUILD_PATH}:
	$(shell ${MKTREE} ${BUILD_PATH})


${OBJS_PATH}:
	$(shell ${MKTREE} ${OBJS_PATH})


# Builds the library
${LIB}: ${OBJS} ${MAIN_OBJ}
ifeq ($(suffix ${MAIN_FILE}),.c)
	${C} ${DEPS_OBJS} ${OBJS} ${MAIN_OBJ} -o ${LIB} ${LIBS} ${LDFLAGS}
else
	${CXX} ${DEPS_OBJS} ${OBJS} ${MAIN_OBJ} -o ${LIB} ${LIBS} ${LDFLAGS}
endif


# Builds the main object
${MAIN_OBJ}: ${MAIN}
ifeq ($(suffix ${MAIN_FILE}),.c)
	${C} -c ${MAIN} -o ${MAIN_OBJ} ${DEPS_INCLUDE} ${INCLUDE} ${CFLAGS}
else
	${CXX} -c ${MAIN} -o ${MAIN_OBJ} ${DEPS_INCLUDE} ${INCLUDE} ${CXXFLAGS}
endif


# Builds all C files mirroring their folder tree
${OBJS_PATH}/%.o: ${SRC}/%.c
	$(shell ${MKTREE} $(dir $@))
	${C} -c $< -o $@ ${DEPS_INCLUDE} ${INCLUDE} ${CFLAGS}


# Builds all CPP files mirroring their folder tree
${OBJS_PATH}/%.o: ${SRC}/%.cpp
	$(shell ${MKTREE} $(dir $@))
	${CXX} -c $< -o $@ ${DEPS_INCLUDE} ${INCLUDE} ${CXXFLAGS}


info:
	$(info PROJECT_NAME: ${PROJECT_NAME})
	$(info LIB: ${LIB})
	$(info DYNAMIC_LIB: ${DYNAMIC_LIB})
	$(info SYSTEM: ${SYSTEM})
	$(info C: ${C})
	$(info CXX: ${CXX})
	$(info MAIN: ${MAIN})
	$(info MAIN_FILE: ${MAIN_FILE})
	$(info MAIN_OBJ: ${MAIN_OBJ})
	$(info C_SRCS: ${C_SRCS})
	$(info CPP_SRCS: ${CPP_SRCS})
	$(info C_HEADERS: ${C_HEADERS})
	$(info CPP_HEADERS: ${CPP_HEADERS})
	$(info SRCS: ${SRCS})
	$(info OBJS: ${OBJS})
	$(info INCLUDED_PATHS: ${INCLUDE})
	$(info LIBS: ${LIBS})
	$(info CFLAGS: ${CFLAGS})
	$(info CXXFLAGS: ${CXXFLAGS})
	$(info LDFLAGS: ${LDFLAGS})
	$(info DEPS_SRCS: ${DEPS_SRCS})
	$(info DEPS_HEADERS: ${DEPS_HEADERS})
	$(info DEPS_INCLUDE: ${DEPS_INCLUDE})
	$(info DEPS_OBJS: ${DEPS_OBJS})

