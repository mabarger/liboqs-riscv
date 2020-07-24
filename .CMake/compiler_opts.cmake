# SPDX-License-Identifier: MIT

if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Werror)
    add_compile_options(-Wall)
    add_compile_options(-Wextra)
    add_compile_options(-Wpedantic)
    add_compile_options(-Wno-unused-command-line-argument)

    if(NOT OQS_BUILD_ONLY_LIB)
        set(THREADS_PREFER_PTHREAD_FLAG ON)
        find_package(Threads REQUIRED)
        set(OQS_USE_PTHREADS_IN_TESTS 1)
    endif()

    if(OQS_USE_CPU_EXTENSIONS)
        include(${CMAKE_CURRENT_LIST_DIR}/gcc_clang_intrinsics.cmake)
    endif()

    if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        add_compile_options(-g3)
        add_compile_options(-fno-omit-frame-pointer)
        if(USE_SANITIZER STREQUAL "Address")
            add_compile_options(-fno-optimize-sibling-calls)
            add_compile_options(-fsanitize-address-use-after-scope)
            add_compile_options(-fsanitize=address)
            set(SANITIZER_LD_FLAGS "-fsanitize=address")
        elseif(USE_SANITIZER STREQUAL "Memory")
            add_compile_options(-fsanitize=address)
            set(SANITIZER_LD_FLAGS "-fsanitize=memory")
        elseif(USE_SANITIZER STREQUAL "MemoryWithOrigins")
            add_compile_options(-fsanitize=memory)
            add_compile_options(-fsanitize-memory-track-origins)
            set(SANITIZER_LD_FLAGS "-fsanitize=memory")
        elseif(USE_SANITIZER STREQUAL "Undefined")
            add_compile_options(-fsanitize=undefined)
            if(EXISTS "${BLACKLIST_FILE}")
                add_compile_options(-fsanitize-blacklist=${BLACKLIST_FILE})
            endif()
            set(SANITIZER_LD_FLAGS "-fsanitize=undefined")
        elseif(USE_SANITIZER STREQUAL "Thread")
            add_compile_options(-fsanitize=thread)
            set(SANITIZER_LD_FLAGS "-fsanitize=thread")
        elseif(USE_SANITIZER STREQUAL "Leak")
            add_compile_options(-fsanitize=leak)
            set(SANITIZER_LD_FLAGS "-fsanitize=leak")
        endif()
    else()
        add_compile_options(-O3)
        add_compile_options(-fomit-frame-pointer)
    endif()

elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Werror)
    add_compile_options(-Wall)
    add_compile_options(-Wextra)
    add_compile_options(-Wpedantic)
    add_compile_options(-Wstrict-prototypes)
    add_compile_options(-Wshadow)
    add_compile_options(-Wformat=2)
    add_compile_options(-Wfloat-equal)
    add_compile_options(-Wwrite-strings)

    if(NOT OQS_BUILD_ONLY_LIB)
        set(THREADS_PREFER_PTHREAD_FLAG ON)
        find_package(Threads REQUIRED)
        set(OQS_USE_PTHREADS_IN_TESTS 1)
    endif()

    if(OQS_USE_CPU_EXTENSIONS)
        include(${CMAKE_CURRENT_LIST_DIR}/gcc_clang_intrinsics.cmake)
    endif()

    if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        add_compile_options (-Wstrict-overflow)
        add_compile_options(-ggdb3)
    else()
        add_compile_options(-O3)
        add_compile_options(-fomit-frame-pointer)
        add_compile_options(-fdata-sections)
        add_compile_options(-ffunction-sections)
        if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            add_compile_options(-Wl,-dead_strip)
        else ()
            add_compile_options(-Wl,--gc-sections)
        endif ()
    endif()

elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    # Warning C4146 is raised when a unary minus operator is applied to an
    # unsigned type; this has nonetheless been standard and portable for as
    # long as there has been a C standard, and we need it for constant-time
    # computations. Thus, we disable that spurious warning.
    add_compile_options(/wd4146)
    # Need a larger stack for Classic McEliece
    add_link_options(/STACK:8192000)
endif()

if(MINGW OR MSYS OR CYGWIN)
    add_compile_options(-Wno-maybe-uninitialized)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.13.0")
        add_link_options(-Wl,--stack,16777216)
    else()
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--stack,1677216")
    endif()
endif()

if(CMAKE_C_IMPLICIT_LINK_DIRECTORIES MATCHES "alpine-linux-musl")
    add_link_options(-Wl,-z,stack-size=16777216)
endif()
