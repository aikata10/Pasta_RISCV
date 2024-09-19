cmake_minimum_required(VERSION 3.10)

project(Cipher LANGUAGES C)

# Include cmake helpers from the common directory.
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/../common" ${CMAKE_MODULE_PATH})
include(postprocessing)
include(objects)

# Specify the build of the actual programs.
add_executable(Cipher  Cipher.c )
pp_create_listing(Cipher)
pp_print_size(Cipher)


pp_copy_ref(Cipher)

