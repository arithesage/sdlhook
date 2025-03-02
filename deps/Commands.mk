ifeq (${SYSTEM},windows)
	MKTREE						:= mkdir
else
	MKTREE						:= mkdir -p
endif

ifeq (${SYSTEM},windows)
	RM							:= del
else
	RM							:= rm
endif


ifeq (${SYSTEM},windows)
	RMTREE						:= deltree
else
	RMTREE						:= rm -r
endif
 

