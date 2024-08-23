#!/bin/bash

set -eux

LLVM_SOURCE=~/work/dpu_tools_llvm_cleanup_20240710_2/llvm-project
COMPILER_RT=${LLVM_SOURCE}/compiler-rt/lib/builtins
COMPILER_RT_TESTS=${LLVM_SOURCE}/compiler-rt/test/builtins/Unit

COMPILER_RT_BUILD=`pwd`

# not supported
# declare -a TESTS_=(
    # absvti2_test.c
    # adddf3vfp_test.c
    # addsf3vfp_test.c
    # addtf3_test.c
    # addvti3_test.c
    # ashlti3_test.c
    # ashrti3_test.c
    # clzti2_test.c
    # cmpti2_test.c
    # compiler_rt_logb_test.c
    # compiler_rt_logbf_test.c
    # compiler_rt_logbl_test.c
    # ctzti2_test.c
    # divdc3_test.c
    # divdf3vfp_test.c
    # divmodti4_test.c
    # divsf3vfp_test.c
    # divsc3_test.c
    # divtc3_test.c
    # divtf3_test.c
    # divti3_test.c
    # divxc3_test.c
    # eqdf2vfp_test.c
    # eqsf2vfp_test.c
    # eqtf2_test.c
    # extenddftf2_test.c
    # extendhftf2_test.c
    # extendsfdf2vfp_test.c
    # extendsftf2_test.c
    # ffsti2_test.c
    # fixdfsivfp_test.c
    # fixdfti_test.c
    # fixsfsivfp_test.c
    # fixsfti_test.c
    # fixtfti_test.c
    # fixunsdfsivfp_test.c
    # fixunsdfti_test.c
    # fixunssfsivfp_test.c
    # fixunssfti_test.c
    # floatditf_test.c
    # floatsidfvfp_test.c
    # floatsisfvfp_test.c
    # floatunditf_test.c
    # floatunssidfvfp_test.c
    # floatunssisfvfp_test.c
    # muldc3_test.c
    # ltdf2vfp_test.c
    # ltsf2vfp_test.c
    # gedf2vfp_test.c
    # gesf2vfp_test.c
    # gtdf2vfp_test.c
    # gtsf2vfp_test.c
    # ledf2vfp_test.c
    # lesf2vfp_test.c
    # muldf3vfp_test.c
    # mulsf3vfp_test.c
    # nedf2vfp_test.c
    # negdf2vfp_test.c
    # negsf2vfp_test.c
    # nesf2vfp_test.c
    # subdf3vfp_test.c
    # subsf3vfp_test.c
    # truncdfsf2vfp_test.c
    # unorddf2vfp_test.c
    # unordsf2vfp_test.c
    # mulsc3_test.c
    # mulxc3_test.c
    # powixf2_test.c
    # subvti3_test.c
    # ucmpti2_test.c
    # udivmodti4_test.c
    # udivti3_test.c
    # umodti3_test.c
    # subtf3_test.c
    # powitf2_test.c
    # negvti2_test.c
    # modti3_test.c
    # muloti4_test.c
    # multc3_test.c
    # multi3_test.c
    # mulvti3_test.c
    # negti2_test.c
    # netf2_test.c
    # parityti2_test.c
    # popcountti2_test.c
    # fixtfdi_test.c
    # fixtfsi_test.c
    # fixunstfdi_test.c
    # fixunstfsi_test.c
    # fixunstfti_test.c
    # fixunsxfdi_test.c
    # fixunsxfsi_test.c
    # fixunsxfti_test.c
    # fixxfti_test.c
    # floatdixf_test.c
    # floatsitf_test.c
    # floattidf_test.c
    # floattisf_test.c
    # floattitf_test.c
    # floattixf_test.c
    # floatundixf_test.c
    # floatunsitf_test.c
    # floatuntidf_test.c
    # floatuntisf_test.c
    # floatuntitf_test.c
    # floatuntixf_test.c
    # getf2_test.c
    # gttf2_test.c
    # letf2_test.c
    # lshrti3_test.c
    # lttf2_test.c
    # multf3_test.c
    # unordtf2_test.c
    # trunctfdf2_test.c
    # trunctfhf2_test.c
    # trunctfsf2_test.c
    # fixxfdi_test.c
    # udivmoddi4_test.c # too big :)
# )

declare -a TESTS=(
    # test.c
    absvdi2_test.c
    absvsi2_test.c
    addvdi3_test.c
    addvsi3_test.c
    ashldi3_test.c
    ashrdi3_test.c
    bswapdi2_test.c
    bswapsi2_test.c
    clzdi2_test.c
    clzsi2_test.c
    cmpdi2_test.c
    comparedf2_test.c
    comparesf2_test.c
    ctzdi2_test.c
    ctzsi2_test.c
    divdf3_test.c
    divdi3_test.c
    divmodsi4_test.c
    divsf3_test.c
    divsi3_test.c
    extendhfsf2_test.c
    ffsdi2_test.c
    ffssi2_test.c
    fixdfdi_test.c
    fixsfdi_test.c
    fixunsdfdi_test.c
    fixunsdfsi_test.c
    fixunssfdi_test.c
    fixunssfsi_test.c
    floatdidf_test.c
    floatdisf_test.c
    floatundidf_test.c
    floatundisf_test.c
    lshrdi3_test.c
    moddi3_test.c
    modsi3_test.c
    muldi3_test.c
    mulodi4_test.c
    mulosi4_test.c
    mulsi3_test.c
    mulvdi3_test.c
    mulvsi3_test.c
    negdi2_test.c
    negvdi2_test.c
    negvsi2_test.c
    paritydi2_test.c
    paritysi2_test.c
    popcountdi2_test.c
    popcountsi2_test.c
    powidf2_test.c
    powisf2_test.c
    subvdi3_test.c
    subvsi3_test.c
    truncdfhf2_test.c
    truncdfsf2_test.c
    truncsfhf2_test.c
    ucmpdi2_test.c
    udivdi3_test.c
    udivmodsi4_test.c
    udivsi3_test.c
    umoddi3_test.c
    umodsi3_test.c
)

declare -a OPT_LEVELS=(
    O0
    O1
    O2
    O3
    Os
)

declare -a COMPILER_OPTIONS=(
    no_lto
    lto
    ltothin
)

MYPWD=`pwd`

mkdir -p test
cd test

for COMPILER_OPTION in "${COMPILER_OPTIONS[@]}"
do
    mkdir -p ${COMPILER_OPTION}
    cd ${COMPILER_OPTION}

    case "$COMPILER_OPTION" in
	"no_lto") COMPILER_OPTION_="";;
	"lto") COMPILER_OPTION_="-flto";;
	"ltothin") COMPILER_OPTION_="-flto=thin";;
    esac

    case "$COMPILER_OPTION" in
	"no_lto") COMPILER_OPTION_LIB="";;
	"lto") COMPILER_OPTION_LIB="lto";;
	"ltothin") COMPILER_OPTION_LIB="ltothin";;
    esac

    for OPT_LEVEL in "${OPT_LEVELS[@]}"
    do
	mkdir -p ${OPT_LEVEL}
	cd ${OPT_LEVEL}

	for TEST in "${TESTS[@]}"
	do
	    clang --target=dpu-upmem-dpurte -mcpu=v1A \
		  -I${COMPILER_RT} \
		  -g0 \
		  -v \
		  -save-temps \
		  -I ${MYPWD} \
		  ${COMPILER_OPTION_} \
		  -${OPT_LEVEL} \
		  ${COMPILER_RT_TESTS}/${TEST} \
		  -o $(basename "${TEST}" .c) \
		  -L ${COMPILER_RT_BUILD} -lrt_${OPT_LEVEL}_${COMPILER_OPTION_LIB} \
		  -mllvm -debug -mllvm -print-after-all -mllvm -verify-machineinstrs \
		&> `basename ${TEST}`_compiler_log.txt

	    # dpu-lldb --batch --one-line run -- $(basename "${TEST}" .c)
	    python3 ${LLVM_SOURCE}/compiler-rt/dpu/lldb_python.py $(basename "${TEST}" .c)
	done
	cd ..
    done

    cd ..
done
cd ..

		  # -L  ~/scratch/dpu_tools/share/upmem/include/built-in/v1A -lrt_v1A \
		  # -save-temps \
		  # -mllvm -debug -mllvm -print-after-all -mllvm -verify-machineinstrs \
		  # --thinlto-jobs=1
