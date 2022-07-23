// Run with verilator --top BinaryToFloat --cc --exe --build binary_to_float*

#include "obj_dir/VBinaryToFloat.h"
#include "verilated.h"
#include <iostream>
#include <random>
#include <limits>

#define FUZZ_TESTS 10000

constexpr uint32_t extract_float_bits(float a) {
    return *(uint32_t*) (&a);
}

constexpr float float_from_bits(uint32_t a) {
    return *(float*) (&a);
}

int32_t random_int32() {
    static std::random_device rd;
    static std::mt19937 e2(rd());
    static std::uniform_real_distribution<> dist(INT32_MIN, INT32_MAX);
    return dist(e2);
}

void test_number(VBinaryToFloat& module, int32_t a) {
    module.in = a;
    module.eval();
    float expected = static_cast<float>(a);
    float got = float_from_bits(module.out);
    if (expected != got && (extract_float_bits(expected) - extract_float_bits(got)) != 1) {
        std::cout << "Invalid result on " << a <<
        ": Expected " << expected << " but got " << got << std::endl;
        std::cout << extract_float_bits(expected) << " " << extract_float_bits(got) << std::endl;
    }
}

int main(int argc, char** argv, char** env) {
    std::cout << "TEST STARTED" << std::endl;
    VerilatedContext context;
    context.commandArgs(argc, argv);
    VBinaryToFloat top(&context);
    // Hardcoded tests
    test_number(top, 0);
    test_number(top, -1);
    test_number(top, 1);
    test_number(top, 1000);
    test_number(top, -1000);
    test_number(top, 280729165);
    // Fuzz
    for (int i = 0; i < FUZZ_TESTS; i++) {
        int32_t a = random_int32();
        test_number(top, a);
        test_number(top, -a);
    }
    // Done
    std::cout << "TEST DONE" << std::endl;
    return 0;
}