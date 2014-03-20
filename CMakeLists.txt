cmake_minimum_required(VERSION 2.8)

find_package(BISON)
find_package(FLEX)

BISON_TARGET(parser ast/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
FLEX_TARGET(lexer ast/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.c)
ADD_FLEX_BISON_DEPENDENCY(lexer parser)

include_directories(${CMAKE_CURRENT_BINARY_DIR} .)

add_executable(videocore-qpu-compiler main.c ast/ast.c ${BISON_parser_OUTPUTS} ${FLEX_lexer_OUTPUTS})

install(TARGETS videocore-qpu-compiler RUNTIME DESTINATION bin)

add_subdirectory(ir)
add_subdirectory(ast)