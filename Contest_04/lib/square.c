#include "square.h"
//
//double root(Function_data *f, Function_data *g, double a, double b, double eps) {
//    double F_x = func_subs(f->func, a) - func_subs(g->func, a);
//    double F_x_prime;
//    double F_x_prime_prime = func_subs(f->func_prime_prime, a) - func_subs(g->func_prime_prime, a);
//
//    double x = (F_x * F_x_prime_prime > 0) ? a : b;
//
//    while (true) {
//        F_x = func_subs(f->func, x) - func_subs(g->func, x);
//
//        if (fabs(F_x) <= eps) {
//            break;
//        }
//
//        F_x_prime = func_subs(f->func_prime, a) - func_subs(g->func_prime, a);
//
//        x = x - F_x / F_x_prime;
//    }
//
//    return x;
//}
//
//double integral(Function *f, double a, double b, double eps) {
//    int32_t n = 10;
//    double p = 1 / 15;
//    double h;
//
//    double I_n;
//    double I_2n;
//    double x;
//
//    while (true) {
//        h = (b - a) / n;
//
//        I_n = func_subs(f, a);
//        for (int i = 0; i < (n / 2) - 1; ++i)
//        {
//            x = a + 2 * i * h;
//            I_n += func_subs(f, x);
//        }
//
//        for (int i = 0; i < n / 2; ++i)
//        {
//            x = a + (2 * i - 1) * h;
//            I_n += func_subs(f, x);
//        }
//
//        I_n += func_subs(f, a + n * h);
//
//
//        n = 2 * n;
//
//        h = (b - a) / n;
//
//        I_2n = func_subs(f, a);
//        for (int i = 0; i < (n / 2) - 1; ++i)
//        {
//            x = a + 2 * i * h;
//            I_2n += func_subs(f, x);
//        }
//
//        for (int i = 0; i < n / 2; ++i)
//        {
//            x = a + (2 * i - 1) * h;
//            I_2n += func_subs(f, x);
//        }
//
//        I_2n += func_subs(f, a + n * h);
//
//        if (p * fabs(I_n - I_2n) < eps) {
//            break;
//        }
//    }
//
//    return I_2n;
//}
//
//int32_t sign(double val) {
//    if (val > 0) {
//        return 1;
//    }
//    else if (val < 0) {
//        return -1;
//    }
//    return 0;
//}