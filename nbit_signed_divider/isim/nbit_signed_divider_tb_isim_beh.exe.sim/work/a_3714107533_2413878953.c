/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "//moyac/usr/vakhl/component/biquad_filter/nbit_signed_divider/nbit_signed_divider.vhd";
extern char *IEEE_P_2592010699;
extern char *IEEE_P_3620187407;

unsigned char ieee_p_2592010699_sub_1744673427_503743352(char *, char *, unsigned int , unsigned int );
char *ieee_p_2592010699_sub_1837678034_503743352(char *, char *, char *, char *);
unsigned char ieee_p_3620187407_sub_4060537613_3965413181(char *, char *, char *, char *, char *);
char *ieee_p_3620187407_sub_436279890_3965413181(char *, char *, char *, char *, int );
char *ieee_p_3620187407_sub_436351764_3965413181(char *, char *, char *, char *, int );
char *ieee_p_3620187407_sub_767740470_3965413181(char *, char *, char *, char *, char *, char *);


static void work_a_3714107533_2413878953_p_0(char *t0)
{
    char t23[16];
    char t26[16];
    char t31[16];
    char t37[16];
    char t42[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    unsigned char t11;
    unsigned char t12;
    unsigned char t13;
    unsigned char t14;
    int t15;
    char *t16;
    char *t17;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    int t22;
    int t24;
    unsigned int t25;
    int t27;
    int t28;
    unsigned int t29;
    unsigned int t30;
    int t32;
    unsigned int t33;
    int t34;
    unsigned int t35;
    unsigned int t36;
    char *t38;
    int t39;
    unsigned int t40;
    char *t41;
    char *t43;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    char *t47;
    char *t48;
    char *t49;
    char *t50;
    char *t51;

LAB0:    xsi_set_current_line(63, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 1472U);
    t3 = ieee_p_2592010699_sub_1744673427_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB5;

LAB6:
LAB3:    t1 = (t0 + 5208);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(64, ng0);
    t1 = xsi_get_transient_memory(32U);
    memset(t1, 0, 32U);
    t5 = t1;
    memset(t5, (unsigned char)2, 32U);
    t6 = (t0 + 5320);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    memcpy(t10, t1, 32U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(65, ng0);
    t1 = (t0 + 5384);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((int *)t7) = 0;
    xsi_driver_first_trans_fast(t1);
    goto LAB3;

LAB5:    xsi_set_current_line(67, ng0);
    t2 = (t0 + 1192U);
    t5 = *((char **)t2);
    t11 = *((unsigned char *)t5);
    t12 = (t11 == (unsigned char)3);
    if (t12 == 1)
        goto LAB10;

LAB11:    t4 = (unsigned char)0;

LAB12:    if (t4 != 0)
        goto LAB7;

LAB9:
LAB8:    goto LAB3;

LAB7:    xsi_set_current_line(68, ng0);
    t2 = (t0 + 2472U);
    t7 = *((char **)t2);
    t15 = *((int *)t7);
    if (t15 == 0)
        goto LAB14;

LAB16:
LAB15:    xsi_set_current_line(76, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t15 = (2 * 32);
    t22 = (t15 - 2);
    t19 = (63 - t22);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t1 = (t2 + t21);
    t5 = (t23 + 0U);
    t6 = (t5 + 0U);
    *((int *)t6) = 62;
    t6 = (t5 + 4U);
    *((int *)t6) = 31;
    t6 = (t5 + 8U);
    *((int *)t6) = -1;
    t24 = (31 - 62);
    t25 = (t24 * -1);
    t25 = (t25 + 1);
    t6 = (t5 + 12U);
    *((unsigned int *)t6) = t25;
    t6 = (t0 + 2312U);
    t7 = *((char **)t6);
    t6 = (t0 + 9132U);
    t3 = ieee_p_3620187407_sub_4060537613_3965413181(IEEE_P_3620187407, t1, t23, t7, t6);
    if (t3 != 0)
        goto LAB18;

LAB20:    xsi_set_current_line(80, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t15 = (2 * 32);
    t22 = (t15 - 2);
    t19 = (63 - t22);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t1 = (t2 + t21);
    t6 = ((IEEE_P_2592010699) + 4024);
    t7 = (t26 + 0U);
    t8 = (t7 + 0U);
    *((int *)t8) = 62;
    t8 = (t7 + 4U);
    *((int *)t8) = 0;
    t8 = (t7 + 8U);
    *((int *)t8) = -1;
    t24 = (0 - 62);
    t25 = (t24 * -1);
    t25 = (t25 + 1);
    t8 = (t7 + 12U);
    *((unsigned int *)t8) = t25;
    t5 = xsi_base_array_concat(t5, t23, t6, (char)97, t1, t26, (char)99, (unsigned char)2, (char)101);
    t25 = (63U + 1U);
    t3 = (64U != t25);
    if (t3 == 1)
        goto LAB25;

LAB26:    t8 = (t0 + 5448);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    t16 = (t10 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t5, 64U);
    xsi_driver_first_trans_fast(t8);

LAB19:    xsi_set_current_line(82, ng0);
    t1 = (t0 + 2472U);
    t2 = *((char **)t1);
    t15 = *((int *)t2);
    t3 = (t15 != 32);
    if (t3 != 0)
        goto LAB27;

LAB29:    xsi_set_current_line(85, ng0);
    t1 = (t0 + 5384);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((int *)t7) = 0;
    xsi_driver_first_trans_fast(t1);

LAB28:
LAB13:    goto LAB8;

LAB10:    t2 = (t0 + 1352U);
    t6 = *((char **)t2);
    t13 = *((unsigned char *)t6);
    t14 = (t13 == (unsigned char)3);
    t4 = t14;
    goto LAB12;

LAB14:    xsi_set_current_line(70, ng0);
    t2 = xsi_get_transient_memory(32U);
    memset(t2, 0, 32U);
    t8 = t2;
    memset(t8, (unsigned char)2, 32U);
    t9 = (t0 + 5448);
    t10 = (t9 + 56U);
    t16 = *((char **)t10);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    memcpy(t18, t2, 32U);
    xsi_driver_first_trans_delta(t9, 0U, 32U, 0LL);
    xsi_set_current_line(71, ng0);
    t1 = (t0 + 2632U);
    t2 = *((char **)t1);
    t1 = (t0 + 5448);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 32U);
    xsi_driver_first_trans_delta(t1, 32U, 32U, 0LL);
    xsi_set_current_line(72, ng0);
    t1 = (t0 + 2792U);
    t2 = *((char **)t1);
    t1 = (t0 + 5512);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 32U);
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(73, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t15 = (32 - 1);
    t19 = (63 - t15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t1 = (t2 + t21);
    t5 = (t0 + 5320);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 32U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(74, ng0);
    t1 = (t0 + 2472U);
    t2 = *((char **)t1);
    t15 = *((int *)t2);
    t22 = (t15 + 1);
    t1 = (t0 + 5384);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((int *)t8) = t22;
    xsi_driver_first_trans_fast(t1);
    goto LAB13;

LAB17:;
LAB18:    xsi_set_current_line(77, ng0);
    t8 = (t0 + 2152U);
    t9 = *((char **)t8);
    t27 = (2 * 32);
    t28 = (t27 - 3);
    t25 = (63 - t28);
    t29 = (t25 * 1U);
    t30 = (0 + t29);
    t8 = (t9 + t30);
    t10 = (t31 + 0U);
    t16 = (t10 + 0U);
    *((int *)t16) = 61;
    t16 = (t10 + 4U);
    *((int *)t16) = 31;
    t16 = (t10 + 8U);
    *((int *)t16) = -1;
    t32 = (31 - 61);
    t33 = (t32 * -1);
    t33 = (t33 + 1);
    t16 = (t10 + 12U);
    *((unsigned int *)t16) = t33;
    t16 = (t0 + 2312U);
    t17 = *((char **)t16);
    t34 = (32 - 2);
    t33 = (31 - t34);
    t35 = (t33 * 1U);
    t36 = (0 + t35);
    t16 = (t17 + t36);
    t18 = (t37 + 0U);
    t38 = (t18 + 0U);
    *((int *)t38) = 30;
    t38 = (t18 + 4U);
    *((int *)t38) = 0;
    t38 = (t18 + 8U);
    *((int *)t38) = -1;
    t39 = (0 - 30);
    t40 = (t39 * -1);
    t40 = (t40 + 1);
    t38 = (t18 + 12U);
    *((unsigned int *)t38) = t40;
    t38 = ieee_p_3620187407_sub_767740470_3965413181(IEEE_P_3620187407, t26, t8, t31, t16, t37);
    t43 = ((IEEE_P_2592010699) + 4024);
    t41 = xsi_base_array_concat(t41, t42, t43, (char)99, (unsigned char)2, (char)97, t38, t26, (char)101);
    t44 = (t26 + 12U);
    t40 = *((unsigned int *)t44);
    t45 = (1U * t40);
    t46 = (1U + t45);
    t4 = (32U != t46);
    if (t4 == 1)
        goto LAB21;

LAB22:    t47 = (t0 + 5448);
    t48 = (t47 + 56U);
    t49 = *((char **)t48);
    t50 = (t49 + 56U);
    t51 = *((char **)t50);
    memcpy(t51, t41, 32U);
    xsi_driver_first_trans_delta(t47, 0U, 32U, 0LL);
    xsi_set_current_line(78, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t15 = (32 - 1);
    t19 = (63 - t15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t1 = (t2 + t21);
    t22 = (32 - 2);
    t25 = (31 - t22);
    t29 = (t25 * 1U);
    t30 = (0 + t29);
    t5 = (t1 + t30);
    t7 = ((IEEE_P_2592010699) + 4024);
    t8 = (t26 + 0U);
    t9 = (t8 + 0U);
    *((int *)t9) = 30;
    t9 = (t8 + 4U);
    *((int *)t9) = 0;
    t9 = (t8 + 8U);
    *((int *)t9) = -1;
    t24 = (0 - 30);
    t33 = (t24 * -1);
    t33 = (t33 + 1);
    t9 = (t8 + 12U);
    *((unsigned int *)t9) = t33;
    t6 = xsi_base_array_concat(t6, t23, t7, (char)97, t5, t26, (char)99, (unsigned char)3, (char)101);
    t33 = (31U + 1U);
    t3 = (32U != t33);
    if (t3 == 1)
        goto LAB23;

LAB24:    t9 = (t0 + 5448);
    t10 = (t9 + 56U);
    t16 = *((char **)t10);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    memcpy(t18, t6, 32U);
    xsi_driver_first_trans_delta(t9, 32U, 32U, 0LL);
    goto LAB19;

LAB21:    xsi_size_not_matching(32U, t46, 0);
    goto LAB22;

LAB23:    xsi_size_not_matching(32U, t33, 0);
    goto LAB24;

LAB25:    xsi_size_not_matching(64U, t25, 0);
    goto LAB26;

LAB27:    xsi_set_current_line(83, ng0);
    t1 = (t0 + 2472U);
    t5 = *((char **)t1);
    t22 = *((int *)t5);
    t24 = (t22 + 1);
    t1 = (t0 + 5384);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    *((int *)t9) = t24;
    xsi_driver_first_trans_fast(t1);
    goto LAB28;

}

static void work_a_3714107533_2413878953_p_1(char *t0)
{
    char t10[16];
    char t11[16];
    char *t1;
    char *t2;
    int t3;
    int t4;
    unsigned int t5;
    unsigned int t6;
    unsigned int t7;
    unsigned char t8;
    unsigned char t9;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    unsigned int t17;
    unsigned int t18;
    unsigned char t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;

LAB0:    xsi_set_current_line(94, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t3 = (32 - 1);
    t4 = (t3 - 31);
    t5 = (t4 * -1);
    t6 = (1U * t5);
    t7 = (0 + t6);
    t1 = (t2 + t7);
    t8 = *((unsigned char *)t1);
    t9 = (t8 == (unsigned char)3);
    if (t9 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(97, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t1 = (t0 + 5576);
    t12 = (t1 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t2, 32U);
    xsi_driver_first_trans_fast(t1);

LAB3:    xsi_set_current_line(99, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t3 = (32 - 1);
    t4 = (t3 - 31);
    t5 = (t4 * -1);
    t6 = (1U * t5);
    t7 = (0 + t6);
    t1 = (t2 + t7);
    t8 = *((unsigned char *)t1);
    t9 = (t8 == (unsigned char)3);
    if (t9 != 0)
        goto LAB7;

LAB9:    xsi_set_current_line(102, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t1 = (t0 + 5640);
    t12 = (t1 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t2, 32U);
    xsi_driver_first_trans_fast(t1);

LAB8:    t1 = (t0 + 5224);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(95, ng0);
    t12 = (t0 + 1672U);
    t13 = *((char **)t12);
    t12 = (t0 + 9068U);
    t14 = ieee_p_3620187407_sub_436351764_3965413181(IEEE_P_3620187407, t11, t13, t12, 1);
    t15 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t10, t14, t11);
    t16 = (t10 + 12U);
    t17 = *((unsigned int *)t16);
    t18 = (1U * t17);
    t19 = (32U != t18);
    if (t19 == 1)
        goto LAB5;

LAB6:    t20 = (t0 + 5576);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t15, 32U);
    xsi_driver_first_trans_fast(t20);
    goto LAB3;

LAB5:    xsi_size_not_matching(32U, t18, 0);
    goto LAB6;

LAB7:    xsi_set_current_line(100, ng0);
    t12 = (t0 + 1832U);
    t13 = *((char **)t12);
    t12 = (t0 + 9084U);
    t14 = ieee_p_3620187407_sub_436351764_3965413181(IEEE_P_3620187407, t11, t13, t12, 1);
    t15 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t10, t14, t11);
    t16 = (t10 + 12U);
    t17 = *((unsigned int *)t16);
    t18 = (1U * t17);
    t19 = (32U != t18);
    if (t19 == 1)
        goto LAB10;

LAB11:    t20 = (t0 + 5640);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t15, 32U);
    xsi_driver_first_trans_fast(t20);
    goto LAB8;

LAB10:    xsi_size_not_matching(32U, t18, 0);
    goto LAB11;

}

static void work_a_3714107533_2413878953_p_2(char *t0)
{
    char t25[16];
    char t26[16];
    char *t1;
    char *t2;
    int t3;
    int t4;
    unsigned int t5;
    unsigned int t6;
    unsigned int t7;
    unsigned char t8;
    unsigned char t9;
    char *t10;
    char *t11;
    int t12;
    int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned char t17;
    unsigned char t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;

LAB0:    xsi_set_current_line(108, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t3 = (32 - 1);
    t4 = (t3 - 31);
    t5 = (t4 * -1);
    t6 = (1U * t5);
    t7 = (0 + t6);
    t1 = (t2 + t7);
    t8 = *((unsigned char *)t1);
    t9 = (t8 == (unsigned char)3);
    if (t9 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(115, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t3 = (32 - 1);
    t4 = (t3 - 31);
    t5 = (t4 * -1);
    t6 = (1U * t5);
    t7 = (0 + t6);
    t1 = (t2 + t7);
    t8 = *((unsigned char *)t1);
    t9 = (t8 == (unsigned char)2);
    if (t9 != 0)
        goto LAB10;

LAB12:    xsi_set_current_line(118, ng0);
    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t1 = (t0 + 9196U);
    t10 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t26, t2, t1);
    t11 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t25, t10, t26, 1);
    t19 = (t25 + 12U);
    t5 = *((unsigned int *)t19);
    t6 = (1U * t5);
    t8 = (32U != t6);
    if (t8 == 1)
        goto LAB13;

LAB14:    t20 = (t0 + 5704);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t11, 32U);
    xsi_driver_first_trans_fast_port(t20);

LAB11:
LAB3:    t1 = (t0 + 5240);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(109, ng0);
    t10 = (t0 + 1832U);
    t11 = *((char **)t10);
    t12 = (32 - 1);
    t13 = (t12 - 31);
    t14 = (t13 * -1);
    t15 = (1U * t14);
    t16 = (0 + t15);
    t10 = (t11 + t16);
    t17 = *((unsigned char *)t10);
    t18 = (t17 == (unsigned char)3);
    if (t18 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(112, ng0);
    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t1 = (t0 + 9196U);
    t10 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t26, t2, t1);
    t11 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t25, t10, t26, 1);
    t19 = (t25 + 12U);
    t5 = *((unsigned int *)t19);
    t6 = (1U * t5);
    t8 = (32U != t6);
    if (t8 == 1)
        goto LAB8;

LAB9:    t20 = (t0 + 5704);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t11, 32U);
    xsi_driver_first_trans_fast_port(t20);

LAB6:    goto LAB3;

LAB5:    xsi_set_current_line(110, ng0);
    t19 = (t0 + 2952U);
    t20 = *((char **)t19);
    t19 = (t0 + 5704);
    t21 = (t19 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t20, 32U);
    xsi_driver_first_trans_fast_port(t19);
    goto LAB6;

LAB8:    xsi_size_not_matching(32U, t6, 0);
    goto LAB9;

LAB10:    xsi_set_current_line(116, ng0);
    t10 = (t0 + 2952U);
    t11 = *((char **)t10);
    t10 = (t0 + 5704);
    t19 = (t10 + 56U);
    t20 = *((char **)t19);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    memcpy(t22, t11, 32U);
    xsi_driver_first_trans_fast_port(t10);
    goto LAB11;

LAB13:    xsi_size_not_matching(32U, t6, 0);
    goto LAB14;

}


extern void work_a_3714107533_2413878953_init()
{
	static char *pe[] = {(void *)work_a_3714107533_2413878953_p_0,(void *)work_a_3714107533_2413878953_p_1,(void *)work_a_3714107533_2413878953_p_2};
	xsi_register_didat("work_a_3714107533_2413878953", "isim/nbit_signed_divider_tb_isim_beh.exe.sim/work/a_3714107533_2413878953.didat");
	xsi_register_executes(pe);
}
