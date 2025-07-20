#!/bin/bash
set -e

echo "Building Graydon DSL compiler..."

# Build the compiler
dune build

# Test with simple example
echo "Testing with working makefile..."
cd examples
echo "Building test makefile..."
echo "program: main.c" > test_working.mk
../_build/default/src/main.exe test_working.mk test_working

if [ -f "test_working" ]; then
    echo "✓ Successfully compiled test makefile to executable"
    echo "Running build system..."
    ./test_working
else
    echo "✗ Failed to compile test makefile"
    exit 1
fi

echo "Compiler is working! Basic tests passed!"