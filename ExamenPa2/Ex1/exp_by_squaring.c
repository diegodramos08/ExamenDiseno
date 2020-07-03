#include <stdio.h>

unsigned int exp_by_squaring(unsigned int x, unsigned int n)
{
    if (n == 0)
        return 1;
    
    unsigned int y = 1;
    while (n > 1)
    {
        if ((n & 1) == 0)
        {
            x = x * x;
            n = n / 2;
        }
        else
        {
            y = x * y;
            x = x * x;
            n = (n - 1) / 2;
        }
    }
    
    return x * y;
}

int main()
{
    printf("2^3 = %d, 7^5 = %u\n",
           exp_by_squaring(2, 3),
           exp_by_squaring(7, 5));
}
