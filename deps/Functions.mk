# ${1}: Source file
define BUILD_C
$(call SRC2OBJ,${1}): ${1}
	${C} -c ${1} -o $(call SRC2OBJ,${1}) ${INCLUDE} ${CFLAGS}
endef

# ${1}: Source file
define BUILD_CPP
$(call SRC2OBJ,${1}): ${1}
	${CXX} -c ${1} -o $(call SRC2OBJ,${1}) ${INCLUDE} ${CXXFLAGS}
endef


# ${1}: Source file
define SRC2OBJ
${OBJS_PATH}/$(notdir $(subst .c,.o,$(subst .cpp,.o,${1})))
endef
