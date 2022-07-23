// Run with verilator --top FP_Rounder --cc --exe --build fp_rounder.sv fp_rounder_sim.cpp

#include "obj_dir/VFP_Rounder.h"
#include "verilated.h"
#include <iostream>
#include <random>

#define FUZZ_TESTS 1000

constexpr uint32_t extract_float_bits(float a) {
    return *(uint32_t*) (&a);
}

constexpr float float_from_bits(uint32_t a) {
    return *(float*) (&a);
}

float random_float() {
    static std::random_device rd;
    static std::mt19937 e2(rd());
    static std::uniform_real_distribution<> dist(-100000, 100000);
    return dist(e2);
}

void test_number(VFP_Rounder& module, float test_case) {
    module.in = extract_float_bits(test_case);
    module.eval();
    int32_t expected = static_cast<int32_t>(test_case + 0.5);
    if (module.out != expected)
        std::cout << "Invalid roudning: " << test_case << " rounded to " << module.out << std::endl;
}

int main(int argc, char** argv, char** env) {
    std::cout << "TEST STARTED" << std::endl;
    VerilatedContext context;
    context.commandArgs(argc, argv);
    VFP_Rounder top(&context);
    // Hardcoded tests
    test_number(top, 0);
    test_number(top, 1);
    test_number(top, -1);
    test_number(top, 10);
    test_number(top, -10);
    test_number(top, 0.5);
    test_number(top, -0.5);
    // Fuzz
    for (int i = 0; i < FUZZ_TESTS; i++) {
        float test_case = random_float();
        test_number(top, test_case);
    }
    // Done
    std::cout << "TEST DONE" << std::endl;
    return 0;
}