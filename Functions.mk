# ${1}: Source file
define SRC2OBJ
$(subst .c,.o,$(subst .cpp,.o,$(subst src,${OBJS_PATH},${1})))
endef
