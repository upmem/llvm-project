cmake_minimum_required(VERSION 3.13)

project(librt C ASM)

set(CMAKE_AR llvm-ar)
set(CMAKE_LINKER llvm-ld)
set(CMAKE_NM llvm-nm)
set(CMAKE_OBJDUMP llvm-objdump)
set(CMAKE_RANLIB llvm-ranlib)
set(OBJCOPY llvm-objcopy)
set(CLANGFORMAT clang-format)

set(COMPILER_RT_BUILTINS_DIR ../lib/builtins)

set(GENERIC_SOURCES
  ${COMPILER_RT_BUILTINS_DIR}/dpu/mul32.S
  ${COMPILER_RT_BUILTINS_DIR}/dpu/mulsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/muldi3.c

  ${COMPILER_RT_BUILTINS_DIR}/dpu/udiv32.S
  # ${COMPILER_RT_BUILTINS_DIR}/dpu/udiv32.c optimized above
  ${COMPILER_RT_BUILTINS_DIR}/dpu/div32.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/divsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/modsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/udivmodsi4.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/udivsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/umodsi3.c

  ${COMPILER_RT_BUILTINS_DIR}/dpu/udiv64.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/divdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/moddi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/udivdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/dpu/umoddi3.c

  ${COMPILER_RT_BUILTINS_DIR}/absvdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/absvsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/adddf3.c
  ${COMPILER_RT_BUILTINS_DIR}/addsf3.c
  ${COMPILER_RT_BUILTINS_DIR}/addvdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/addvsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/ashldi3.c
  ${COMPILER_RT_BUILTINS_DIR}/ashrdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/bswapdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/bswapsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/clzdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/clzsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/cmpdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/comparedf2.c
  ${COMPILER_RT_BUILTINS_DIR}/comparesf2.c
  ${COMPILER_RT_BUILTINS_DIR}/ctzdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/ctzsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/divdf3.c
  ${COMPILER_RT_BUILTINS_DIR}/divdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/divmoddi4.c
  ${COMPILER_RT_BUILTINS_DIR}/divmodsi4.c
  ${COMPILER_RT_BUILTINS_DIR}/divsf3.c
  ${COMPILER_RT_BUILTINS_DIR}/divsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/extendsfdf2.c
  ${COMPILER_RT_BUILTINS_DIR}/extendhfsf2.c
  ${COMPILER_RT_BUILTINS_DIR}/ffsdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/ffssi2.c
  ${COMPILER_RT_BUILTINS_DIR}/fixdfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixdfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixsfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixsfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunsdfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunsdfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunssfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunssfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/floatdidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatdisf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatsidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatsisf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatundidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatundisf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatunsidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatunsisf.c
  ${COMPILER_RT_BUILTINS_DIR}/fp_mode.c
  ${COMPILER_RT_BUILTINS_DIR}/int_util.c
  ${COMPILER_RT_BUILTINS_DIR}/lshrdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/moddi3.c
  ${COMPILER_RT_BUILTINS_DIR}/modsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/muldf3.c
  ${COMPILER_RT_BUILTINS_DIR}/muldi3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulodi4.c
  ${COMPILER_RT_BUILTINS_DIR}/mulosi4.c
  ${COMPILER_RT_BUILTINS_DIR}/mulsf3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulvdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulvsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/negdf2.c
  ${COMPILER_RT_BUILTINS_DIR}/negdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/negsf2.c
  ${COMPILER_RT_BUILTINS_DIR}/negvdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/negvsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/paritydi2.c
  ${COMPILER_RT_BUILTINS_DIR}/paritysi2.c
  ${COMPILER_RT_BUILTINS_DIR}/popcountdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/popcountsi2.c
  ${COMPILER_RT_BUILTINS_DIR}/powidf2.c
  ${COMPILER_RT_BUILTINS_DIR}/powisf2.c
  ${COMPILER_RT_BUILTINS_DIR}/subdf3.c
  ${COMPILER_RT_BUILTINS_DIR}/subsf3.c
  ${COMPILER_RT_BUILTINS_DIR}/subvdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/subvsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/truncdfhf2.c
  ${COMPILER_RT_BUILTINS_DIR}/truncdfsf2.c
  ${COMPILER_RT_BUILTINS_DIR}/truncsfhf2.c
  ${COMPILER_RT_BUILTINS_DIR}/ucmpdi2.c
  ${COMPILER_RT_BUILTINS_DIR}/udivdi3.c
  ${COMPILER_RT_BUILTINS_DIR}/udivmoddi4.c
  ${COMPILER_RT_BUILTINS_DIR}/udivmodsi4.c
  ${COMPILER_RT_BUILTINS_DIR}/udivsi3.c
  ${COMPILER_RT_BUILTINS_DIR}/umoddi3.c
  ${COMPILER_RT_BUILTINS_DIR}/umodsi3.c
  )

set(GENERIC_TF_SOURCES
  ${COMPILER_RT_BUILTINS_DIR}/addtf3.c
  ${COMPILER_RT_BUILTINS_DIR}/addvti3.c
  ${COMPILER_RT_BUILTINS_DIR}/absvti2.c
  ${COMPILER_RT_BUILTINS_DIR}/ashrti3.c
  ${COMPILER_RT_BUILTINS_DIR}/comparetf2.c
  ${COMPILER_RT_BUILTINS_DIR}/clzti2.c
  ${COMPILER_RT_BUILTINS_DIR}/cmpti2.c
  ${COMPILER_RT_BUILTINS_DIR}/ctzti2.c
  ${COMPILER_RT_BUILTINS_DIR}/divtf3.c
  ${COMPILER_RT_BUILTINS_DIR}/divmodti4.c
  ${COMPILER_RT_BUILTINS_DIR}/divti3.c
  ${COMPILER_RT_BUILTINS_DIR}/extenddftf2.c
  ${COMPILER_RT_BUILTINS_DIR}/extendhftf2.c
  ${COMPILER_RT_BUILTINS_DIR}/extendsftf2.c
  ${COMPILER_RT_BUILTINS_DIR}/ffsti2.c
  ${COMPILER_RT_BUILTINS_DIR}/fixdfti.c
  ${COMPILER_RT_BUILTINS_DIR}/fixsfti.c
  ${COMPILER_RT_BUILTINS_DIR}/fixtfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixtfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixtfti.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunsdfti.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunssfti.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunstfdi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunstfsi.c
  ${COMPILER_RT_BUILTINS_DIR}/fixunstfti.c
  ${COMPILER_RT_BUILTINS_DIR}/floatditf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatsitf.c
  ${COMPILER_RT_BUILTINS_DIR}/floattidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floattisf.c
  ${COMPILER_RT_BUILTINS_DIR}/floattitf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatunditf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatunsitf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatuntidf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatuntisf.c
  ${COMPILER_RT_BUILTINS_DIR}/floatuntitf.c
  ${COMPILER_RT_BUILTINS_DIR}/lshrti3.c
  ${COMPILER_RT_BUILTINS_DIR}/modti3.c
  ${COMPILER_RT_BUILTINS_DIR}/muloti4.c
  ${COMPILER_RT_BUILTINS_DIR}/multf3.c
  ${COMPILER_RT_BUILTINS_DIR}/multi3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulvti3.c
  ${COMPILER_RT_BUILTINS_DIR}/negti2.c
  ${COMPILER_RT_BUILTINS_DIR}/negvti2.c
  ${COMPILER_RT_BUILTINS_DIR}/popcountti2.c
  ${COMPILER_RT_BUILTINS_DIR}/powitf2.c
  ${COMPILER_RT_BUILTINS_DIR}/subtf3.c
  ${COMPILER_RT_BUILTINS_DIR}/subvti3.c
  ${COMPILER_RT_BUILTINS_DIR}/trunctfdf2.c
  ${COMPILER_RT_BUILTINS_DIR}/trunctfhf2.c
  ${COMPILER_RT_BUILTINS_DIR}/trunctfsf2.c
  ${COMPILER_RT_BUILTINS_DIR}/ucmpti2.c
  ${COMPILER_RT_BUILTINS_DIR}/udivmodti4.c
  ${COMPILER_RT_BUILTINS_DIR}/udivti3.c
  ${COMPILER_RT_BUILTINS_DIR}/umodti3.c
  )

set(GENERIC_COMPLEX_SOURCES
  ${COMPILER_RT_BUILTINS_DIR}/divdc3.c
  ${COMPILER_RT_BUILTINS_DIR}/divsc3.c
  ${COMPILER_RT_BUILTINS_DIR}/muldc3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulsc3.c
  )

set(GENERIC_COMPLEX_TF_SOURCES
  ${COMPILER_RT_BUILTINS_DIR}/divdc3.c
  ${COMPILER_RT_BUILTINS_DIR}/divsc3.c
  ${COMPILER_RT_BUILTINS_DIR}/divtc3.c
  ${COMPILER_RT_BUILTINS_DIR}/muldc3.c
  ${COMPILER_RT_BUILTINS_DIR}/mulsc3.c
  ${COMPILER_RT_BUILTINS_DIR}/multc3.c
  )

set(SOURCES ${GENERIC_SOURCES}
  # ${GENERIC_TF_SOURCES}
  # ${GENERIC_COMPLEX}
  # ${GENERIC_COMPLEX_TF_SOURCES}
  )

function(add_dpu_library)
  set(options PROFILING)
  set(oneValueArgs TARGET OPT_LEVEL LTO)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  message("ARGN: ${ARGN}")

  message(${options})
  message(${oneValueArgs})
  message(${multiValueArgs})

  message("TARGET: ${arg_TARGET}")
  message("OPT_LEVEL: ${arg_OPT_LEVEL}")
  message("PROFILING: ${arg_PROFILING}")
  message("LTO: ${arg_LTO}")
  message("LTO_TYPE: ${arg_LTO_TYPE}")

  set(LOCAL_TARGET ${arg_TARGET})

  set(OTHER_FLAGS)
  list(APPEND OTHER_FLAGS -Wall)
  list(APPEND OTHER_FLAGS -Wextra)

  if (arg_OPT_LEVEL)
    list(APPEND OTHER_FLAGS ${arg_OPT_LEVEL})
    string(REPLACE "-" "" arg_OPT_LEVEL ${arg_OPT_LEVEL})
    string(APPEND LOCAL_TARGET "_${arg_OPT_LEVEL}")
  endif()
  if (arg_LTO)
    list(APPEND OTHER_FLAGS ${arg_LTO})
    string(REPLACE "-f" "" arg_LTO ${arg_LTO})
    string(REPLACE "=" "" arg_LTO ${arg_LTO})
    string(APPEND LOCAL_TARGET "_${arg_LTO}")
  else()
    string(APPEND LOCAL_TARGET "_")
  endif()
  if (arg_PROFILING)
    list(APPEND OTHER_FLAGS -pg)
    string(APPEND LOCAL_TARGET "_pg")
  endif()

  list(APPEND OTHER_FLAGS -g0)
  list(APPEND OTHER_FLAGS -mllvm -verify-machineinstrs)
  # list(APPEND OTHER_FLAGS -mllvm -debug) --> deduped

  message("LOCAL_TARGET: ${LOCAL_TARGET}")
  message("OTHER_FLAGS: ${OTHER_FLAGS}")

  add_library(${LOCAL_TARGET} STATIC "${arg_SOURCES}")

  target_include_directories(${LOCAL_TARGET} PRIVATE
    ${COMPILER_RT_BUILTINS_DIR}
    ${COMPILER_RT_BUILTINS_DIR}/dpu)

  target_compile_options(${LOCAL_TARGET}
    PRIVATE ${NOSTDLIB_FLAGS} ${STRICT_FLAGS} ${COMPILER_TIMESTAMP_DEF} ${OTHER_FLAGS})

  # set_target_properties(${LOCAL_TARGET} PROPERTIES OUTPUT_NAME "rt")

  if (arg_LTO)
    install(
      TARGETS ${LOCAL_TARGET}
      ARCHIVE
      DESTINATION ${arg_OPT_LEVEL}/${arg_LTO}
      )
  else()
    install(
      TARGETS ${LOCAL_TARGET}
      ARCHIVE
      DESTINATION ${arg_OPT_LEVEL}/no_lto
      )
  endif()
endfunction()

# add_dpu_library(
#     TARGET rt
#     OPT_LEVEL -O3
#     # LTO -flto
#     # PROFILING
#     SOURCES ${SOURCES}
#     )

foreach(OPT_LEVEL -O0;-O1;-O2;-O3;-Os)
  add_dpu_library(
    TARGET rt
    OPT_LEVEL ${OPT_LEVEL}
    SOURCES ${SOURCES}
    )
  # add_dpu_library(
  #   TARGET rt
  #   OPT_LEVEL ${OPT_LEVEL}
  #   PROFILING
  #   SOURCES ${SOURCES}
  #   )
  foreach(LTO -flto;-flto=thin)
    add_dpu_library(
      TARGET rt
      OPT_LEVEL ${OPT_LEVEL}
      LTO ${LTO}
      SOURCES ${SOURCES}
      )
    # add_dpu_library(
    #   TARGET rt
    #   OPT_LEVEL ${OPT_LEVEL}
    #   LTO ${LTO}
    #   PROFILING
    #   SOURCES ${SOURCES}
    #   )
  endforeach()
endforeach()
