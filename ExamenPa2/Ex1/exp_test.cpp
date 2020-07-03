#include <iostream>
#include "VExp.h"
#include "VExp_Exp.h"

#define FINAL 0x3

void reset(VExp& vexp)
{
    vexp.rst = 1;
    vexp.clk = 0;
    vexp.eval();
    vexp.clk = 1;
    vexp.eval();
    vexp.rst = 0;
    vexp.eval();
}

unsigned exp(VExp& vexp, unsigned x, unsigned n)
{
    reset(vexp);

    vexp.x = x;
    vexp.n = n;
    
    while (vexp.Exp->cs != FINAL)
    {
        vexp.clk = !vexp.clk;
        vexp.eval();
    }

    return vexp.res;
}

int main()
{
    VExp vexp;

    std::cout << "2^3 = " << exp(vexp, 2, 3) << '\n';
    std::cout << "7^5 = " << exp(vexp, 7, 5) << '\n';

    vexp.final();

    return 0;
}
