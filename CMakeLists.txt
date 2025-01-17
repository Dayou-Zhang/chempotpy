cmake_minimum_required(VERSION 3.16)

project(toy
  LANGUAGES C Fortran
  )

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module NumPy)

find_package(BLAS REQUIRED)
message("BLAS found. ${BLAS_LIBRARIES}")

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

    add_custom_command(
      OUTPUT "${module_build_dir}/${f2py_module_sig}" "${module_build_dir}/${f2py_module_src}"
      COMMAND mkdir -p "${module_build_dir}"
      COMMAND cp "${f2py_signature_file}" "${module_build_dir}"
      COMMAND cp "${fortran_src_file}" "${module_build_dir}"
      DEPENDS "${f2py_signature_file}" "${fortran_src_file}"
    )

    message("processing ${module_build_dir}")
    add_custom_command(
      OUTPUT "${module_build_dir}/${f2py_module_c}" "${module_build_dir}/${f2py_module_f}"
      COMMAND ${Python_EXECUTABLE}  -m "numpy.f2py"
                       "${module_build_dir}/${f2py_module_sig}"
                       --lower
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

    target_link_libraries(${f2py_module_name} PUBLIC Python::NumPy ${BLAS_LIBRARIES})

    file(RELATIVE_PATH install_dir ${CMAKE_SOURCE_DIR} ${f2py_dir_name})
    install(TARGETS ${f2py_module_name} DESTINATION "${install_dir}")

endforeach()
