BCYAN   = \033[1;36m
RESET   = \033[0m

BRANCH	= main
TARGET 	= ./_asm
MESSAGE = 04-9: Матрица с максимальным следом. Sample 24

machine_control_sign:
	printf	"${BCYAN}>>>${RESET} "

assign_local:
	@make machine_control_sign
	git add ${TARGET}

	@make machine_control_sign
	git commit -m "${MESSAGE}"

push_remote:
	@make machine_control_sign
	git push origin ${BRANCH}