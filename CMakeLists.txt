cmake_minimum_required(VERSION 3.18)

project(toy
  LANGUAGES C Fortran
  )

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module NumPy)
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

# f2py headers
execute_process(
  COMMAND "${Python_EXECUTABLE}"
  -c "import numpy.f2py; print(numpy.f2py.get_include())"
  OUTPUT_VARIABLE F2PY_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

file(GLOB_RECURSE sources "*_*.f" "*_*.f90")

# Compile each f2py module
foreach(fortran_src_file ${sources})
    get_filename_component(f2py_module_name ${fortran_src_file} NAME_WE)
    get_filename_component(f2py_module_src ${fortran_src_file} NAME)
    get_filename_component(f2py_dir_name ${fortran_src_file} DIRECTORY)
    set(f2py_module_c "${f2py_module_name}module.c")
    set(f2py_module_f "${f2py_module_name}-f2pywrappers.f")
    string(REGEX REPLACE "[.]f(90)?$" ".pyf" f2py_signature_file ${fortran_src_file})
    get_filename_component(f2py_module_sig ${f2py_signature_file} NAME)
    set(module_build_dir "${CMAKE_BINARY_DIR}/${f2py_module_name}")

    # F2PY have to generate all wrapper source files in the same directory
    # as the Fortran files. We need to copy the Fortran files to the build
    # directories to avoid contaminating the source directory.
    add_custom_command(
      OUTPUT "${module_build_dir}/${f2py_module_sig}" "${module_build_dir}/${f2py_module_src}"
      COMMAND mkdir -p "${module_build_dir}"
      COMMAND cp "${f2py_signature_file}" "${module_build_dir}"
      COMMAND cp "${fortran_src_file}" "${module_build_dir}"
      DEPENDS "${f2py_signature_file}" "${fortran_src_file}"
    )

    message("processing ${f2py_dir_name}/${f2py_module_src}")
    add_custom_command(
      OUTPUT "${module_build_dir}/${f2py_module_c}" "${module_build_dir}/${f2py_module_f}"
      COMMAND ${Python_EXECUTABLE}  -m "numpy.f2py"
                       "${module_build_dir}/${f2py_module_sig}"
      DEPENDS "${module_build_dir}/${f2py_module_sig}" "${module_build_dir}/${f2py_module_src}"
      WORKING_DIRECTORY "${module_build_dir}"
    )

    python_add_library(${f2py_module_name} MODULE
        "${module_build_dir}/${f2py_module_c}"
        "${module_build_dir}/${f2py_module_f}"
        "${F2PY_INCLUDE_DIR}/fortranobject.c"
        "${fortran_src_file}" WITH_SOABI
    )

    target_include_directories(${f2py_module_name} PUBLIC
        ${F2PY_INCLUDE_DIR}
    )

    target_link_libraries(${f2py_module_name} PUBLIC Python::NumPy BLAS::BLAS LAPACK::LAPACK)

    # Make sure .mod files are generate in seperate directories
    # Some Fortran files may contain modules of the same name, which could
    # conflict with each other.
    set_target_properties(${f2py_module_name} PROPERTIES
        Fortran_MODULE_DIRECTORY "${module_build_dir}"
    )

    file(RELATIVE_PATH install_dir ${CMAKE_SOURCE_DIR} ${f2py_dir_name})
    install(TARGETS ${f2py_module_name} DESTINATION "${install_dir}")

endforeach()

# Some old codes rely on implicit dimension conversion.
# They need to be compiled with -std=legacy in gfortran
target_compile_options(NaH2_LEPS_6_2000_DPEM PRIVATE -std=legacy)
target_compile_options(OH2_Ap_GEN_M21986 PRIVATE -std=legacy)
target_compile_options(OH2_App_GEN_M21986 PRIVATE -std=legacy)
target_compile_options(OH2_App_GEN_M3n1988 PRIVATE -std=legacy)
target_compile_options(OH2_App_GEN_M3na1988 PRIVATE -std=legacy)
