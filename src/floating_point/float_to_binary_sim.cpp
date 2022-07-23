// Run with verilator --top FloatToBinary --cc --exe --build float_to_binary*

#include "obj_dir/VFloatToBinary.h"
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

float random_float() {
    static std::random_device rd;
    static std::mt19937 e2(rd());
    static std::uniform_real_distribution<> dist(-1000, 1000);
    return dist(e2);
}

void test_number(VFloatToBinary& module, float a) {
    module.in = extract_float_bits(a);
    module.eval();
    int32_t expected = static_cast<int32_t>(a);
    int32_t got = module.out;
    if (expected != got) {
        std::cout << "Invalid result on " << a <<
        ": Expected " << expected << " but got " << got << std::endl;
        std::cout << extract_float_bits(expected) << " " << extract_float_bits(got) << std::endl;
    }
}

int main(int argc, char** argv, char** env) {
    std::cout << "TEST STARTED" << std::endl;
    VerilatedContext context;
    context.commandArgs(argc, argv);
    VFloatToBinary top(&context);
    // Hardcoded tests
    test_number(top, 0);
    test_number(top, -1);
    test_number(top, 1);
    test_number(top, 1000);
    test_number(top, -1000);
    test_number(top, 280729165);
    // Fuzz
    for (int i = 0; i < FUZZ_TESTS; i++) {
        int32_t a = random_float();
        test_number(top, a);
        test_number(top, -a);
    }
    // Done
    std::cout << "TEST DONE" << std::endl;
    return 0;
}