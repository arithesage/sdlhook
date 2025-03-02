include Project.mk


EXEC							:= ${PROJECT_NAME}

ifneq (${WINDIR},)
	SYSTEM						:= windows
	EXEC						:= ${EXEC}.exe
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

SRC								:= src
DEPS							:= deps
BUILD							:= build
OBJ								:= obj

OBJS_PATH						:= ${OBJ}/${SYSTEM}
DEPS_OBJS_PATH						:= $(DEPS)/${OBJ}/${SYSTEM}
BUILD_PATH						:= ${BUILD}/${SYSTEM}

EXEC							:= ${BUILD}/${SYSTEM}/${EXEC}


include Commands.mk
include Functions.mk

C_MAIN							:= $(shell find ${SRC}/** -type f -name "main.c")
CPP_MAIN						:= $(shell find ${SRC}/** -type f -name "main.cpp")

ifneq (${C_MAIN},)
	MAIN						:= ${C_MAIN}
else
	MAIN						:= ${CPP_MAIN}
endif

MAIN_FILE						:= $(notdir ${MAIN})
MAIN_OBJ						:= ${OBJS_PATH}/$(call SRC2OBJ,${MAIN_FILE})

C_SRCS							:= $(shell find ${SRC}/** -type f -name "*.c" -not -name "main.c")
CPP_SRCS						:= $(shell find ${SRC}/** -type f -name "*.cpp" -not -name "main.cpp")

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

ifeq (${C},)
	C							:= clang
endif

ifeq (${CXX},)
	CXX							:= clang++
endif




.PHONY: all cleandeps deps clean info run


all: ${OBJS_PATH} ${BUILD_PATH} ${EXEC}


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


# Builds the executable
${EXEC}: ${OBJS} ${MAIN_OBJ}
ifeq (${MAIN_FILE},main.c)
	${C} ${DEPS_OBJS} ${OBJS} ${MAIN_OBJ} -o ${EXEC} ${LIBS} ${LDFLAGS}
else
	${CXX} ${DEPS_OBJS} ${OBJS} ${MAIN_OBJ} -o ${EXEC} ${LIBS} ${LDFLAGS}
endif


# Builds the main object
${MAIN_OBJ}: ${MAIN}
ifeq (${MAIN_FILE},main.c)
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
	$(info EXEC: ${EXEC})
	$(info SYSTEM: ${SYSTEM})
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
	$(info DEPS_SRCS: ${DEPS_SRCS})
	$(info DEPS_HEADERS: ${DEPS_HEADERS})
	$(info DEPS_INCLUDE: ${DEPS_INCLUDE})
	$(info DEPS_OBJS: ${DEPS_OBJS})


run:
ifeq (${SYSTEM},windows)
	${EXEC}
else
	./${EXEC}
endif
