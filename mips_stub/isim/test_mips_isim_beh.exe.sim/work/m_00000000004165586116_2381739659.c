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

/* This file is designed for use with ISim build 0xc3576ebc */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/brownell/Downloads/mips_stub/mips_stub/mips_stub/cpu_rtl/memory.v";
static const char *ng1 = "out.machine";
static const char *ng2 = "w";
static int ng3[] = {0, 0};
static int ng4[] = {4096, 0};
static const char *ng5 = "%h\n";
static int ng6[] = {1, 0};
static unsigned int ng7[] = {0U, 0U};
static int ng8[] = {1751740005, 0, 778920291, 0, 26990, 0};



static int sp_dump(char *t1, char *t2)
{
    char t5[8];
    char t21[8];
    int t0;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;
    char *t30;
    char *t31;

LAB0:    t0 = 1;
    t3 = (t2 + 48U);
    t4 = *((char **)t3);
    if (t4 == 0)
        goto LAB2;

LAB3:    goto *t4;

LAB2:    t4 = (t1 + 1120);
    xsi_vlog_subprogram_setdisablestate(t4, &&LAB4);
    xsi_set_current_line(52, ng0);

LAB5:    xsi_set_current_line(53, ng0);
    *((int *)t5) = xsi_vlogfile_file_open_of_cname_ctype(ng1, ng2);
    t6 = (t5 + 4);
    *((int *)t6) = 0;
    t7 = (t1 + 4072);
    xsi_vlogvar_assign_value(t7, t5, 0, 0, 32);
    xsi_set_current_line(54, ng0);
    xsi_set_current_line(54, ng0);
    t4 = ((char*)((ng3)));
    t6 = (t1 + 3912);
    xsi_vlogvar_assign_value(t6, t4, 0, 0, 32);

LAB6:    t4 = (t1 + 3912);
    t6 = (t4 + 56U);
    t7 = *((char **)t6);
    t8 = ((char*)((ng4)));
    memset(t5, 0, 8);
    xsi_vlog_signed_less(t5, 32, t7, 32, t8, 32);
    t9 = (t5 + 4);
    t10 = *((unsigned int *)t9);
    t11 = (~(t10));
    t12 = *((unsigned int *)t5);
    t13 = (t12 & t11);
    t14 = (t13 != 0);
    if (t14 > 0)
        goto LAB7;

LAB8:    xsi_set_current_line(57, ng0);
    t4 = (t1 + 4072);
    t6 = (t4 + 56U);
    t7 = *((char **)t6);
    xsi_vlogfile_fclose(*((unsigned int *)t7));

LAB4:    xsi_vlog_dispose_subprogram_invocation(t2);
    t4 = (t2 + 48U);
    *((char **)t4) = &&LAB2;
    t0 = 0;

LAB1:    return t0;
LAB7:    xsi_set_current_line(54, ng0);

LAB9:    xsi_set_current_line(55, ng0);
    t15 = (t1 + 4072);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    t18 = (t1 + 3752);
    t19 = (t18 + 56U);
    t20 = *((char **)t19);
    t22 = (t1 + 3752);
    t23 = (t22 + 72U);
    t24 = *((char **)t23);
    t25 = (t1 + 3752);
    t26 = (t25 + 64U);
    t27 = *((char **)t26);
    t28 = (t1 + 3912);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    xsi_vlog_generic_get_array_select_value(t21, 32, t20, t24, t27, 2, 1, t30, 32, 1);
    t31 = (t1 + 1120);
    xsi_vlogfile_fwrite(*((unsigned int *)t17), 0, 0, 1, ng5, 2, t31, (char)118, t21, 32);
    xsi_set_current_line(54, ng0);
    t4 = (t1 + 3912);
    t6 = (t4 + 56U);
    t7 = *((char **)t6);
    t8 = ((char*)((ng6)));
    memset(t5, 0, 8);
    xsi_vlog_signed_add(t5, 32, t7, 32, t8, 32);
    t9 = (t1 + 3912);
    xsi_vlogvar_assign_value(t9, t5, 0, 0, 32);
    goto LAB6;

}

static void Cont_21_0(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;

LAB0:    t1 = (t0 + 5152U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(21, ng0);
    t2 = (t0 + 2072U);
    t4 = *((char **)t2);
    memset(t3, 0, 8);
    t2 = (t3 + 4);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 2);
    *((unsigned int *)t3) = t7;
    t8 = *((unsigned int *)t5);
    t9 = (t8 >> 2);
    *((unsigned int *)t2) = t9;
    t10 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t10 & 4095U);
    t11 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t11 & 4095U);
    t12 = (t0 + 6328);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memset(t16, 0, 8);
    t17 = 4095U;
    t18 = t17;
    t19 = (t3 + 4);
    t20 = *((unsigned int *)t3);
    t17 = (t17 & t20);
    t21 = *((unsigned int *)t19);
    t18 = (t18 & t21);
    t22 = (t16 + 4);
    t23 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t23 | t17);
    t24 = *((unsigned int *)t22);
    *((unsigned int *)t22) = (t24 | t18);
    xsi_driver_vfirst_trans(t12, 0, 11);
    t25 = (t0 + 6216);
    *((int *)t25) = 1;

LAB1:    return;
}

static void Cont_29_1(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 5400U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(29, ng0);
    t2 = (t0 + 4232);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 6392);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t4, 8);
    xsi_driver_vfirst_trans(t5, 0, 31);
    t10 = (t0 + 6232);
    *((int *)t10) = 1;

LAB1:    return;
}

static void Initial_31_2(char *t0)
{
    char t5[8];
    char t14[8];
    char t15[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    unsigned int t26;
    int t27;
    char *t28;
    unsigned int t29;
    int t30;
    int t31;
    unsigned int t32;
    unsigned int t33;
    int t34;
    int t35;

LAB0:    xsi_set_current_line(31, ng0);

LAB2:    xsi_set_current_line(34, ng0);
    xsi_set_current_line(34, ng0);
    t1 = ((char*)((ng3)));
    t2 = (t0 + 3912);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 32);

LAB3:    t1 = (t0 + 3912);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng4)));
    memset(t5, 0, 8);
    xsi_vlog_signed_less(t5, 32, t3, 32, t4, 32);
    t6 = (t5 + 4);
    t7 = *((unsigned int *)t6);
    t8 = (~(t7));
    t9 = *((unsigned int *)t5);
    t10 = (t9 & t8);
    t11 = (t10 != 0);
    if (t11 > 0)
        goto LAB4;

LAB5:    xsi_set_current_line(38, ng0);
    t1 = ((char*)((ng8)));
    t2 = (t0 + 3752);
    xsi_vlogfile_readmemh(t1, 80, t2, 0, 0, 0, 0);

LAB1:    return;
LAB4:    xsi_set_current_line(34, ng0);

LAB6:    xsi_set_current_line(35, ng0);
    t12 = ((char*)((ng7)));
    t13 = (t0 + 3752);
    t16 = (t0 + 3752);
    t17 = (t16 + 72U);
    t18 = *((char **)t17);
    t19 = (t0 + 3752);
    t20 = (t19 + 64U);
    t21 = *((char **)t20);
    t22 = (t0 + 3912);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    xsi_vlog_generic_convert_array_indices(t14, t15, t18, t21, 2, 1, t24, 32, 1);
    t25 = (t14 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (!(t26));
    t28 = (t15 + 4);
    t29 = *((unsigned int *)t28);
    t30 = (!(t29));
    t31 = (t27 && t30);
    if (t31 == 1)
        goto LAB7;

LAB8:    xsi_set_current_line(34, ng0);
    t1 = (t0 + 3912);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng6)));
    memset(t5, 0, 8);
    xsi_vlog_signed_add(t5, 32, t3, 32, t4, 32);
    t6 = (t0 + 3912);
    xsi_vlogvar_assign_value(t6, t5, 0, 0, 32);
    goto LAB3;

LAB7:    t32 = *((unsigned int *)t14);
    t33 = *((unsigned int *)t15);
    t34 = (t32 - t33);
    t35 = (t34 + 1);
    xsi_vlogvar_assign_value(t13, t12, 0, *((unsigned int *)t15), t35);
    goto LAB8;

}

static void Always_41_3(char *t0)
{
    char t13[8];
    char t14[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    unsigned int t23;
    int t24;
    char *t25;
    unsigned int t26;
    int t27;
    int t28;
    unsigned int t29;
    unsigned int t30;
    int t31;
    int t32;

LAB0:    t1 = (t0 + 5896U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(41, ng0);
    t2 = (t0 + 6248);
    *((int *)t2) = 1;
    t3 = (t0 + 5928);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(41, ng0);

LAB5:    xsi_set_current_line(42, ng0);
    t4 = (t0 + 1912U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(46, ng0);

LAB12:    xsi_set_current_line(47, ng0);
    t2 = (t0 + 3752);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 3752);
    t11 = (t5 + 72U);
    t12 = *((char **)t11);
    t15 = (t0 + 3752);
    t16 = (t15 + 64U);
    t17 = *((char **)t16);
    t18 = (t0 + 3352U);
    t19 = *((char **)t18);
    xsi_vlog_generic_get_array_select_value(t13, 32, t4, t12, t17, 2, 1, t19, 12, 2);
    t18 = (t0 + 4232);
    xsi_vlogvar_wait_assign_value(t18, t13, 0, 0, 32, 0LL);

LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(42, ng0);

LAB9:    xsi_set_current_line(43, ng0);
    t11 = (t0 + 2232U);
    t12 = *((char **)t11);
    t11 = (t0 + 3752);
    t15 = (t0 + 3752);
    t16 = (t15 + 72U);
    t17 = *((char **)t16);
    t18 = (t0 + 3752);
    t19 = (t18 + 64U);
    t20 = *((char **)t19);
    t21 = (t0 + 3352U);
    t22 = *((char **)t21);
    xsi_vlog_generic_convert_array_indices(t13, t14, t17, t20, 2, 1, t22, 12, 2);
    t21 = (t13 + 4);
    t23 = *((unsigned int *)t21);
    t24 = (!(t23));
    t25 = (t14 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (!(t26));
    t28 = (t24 && t27);
    if (t28 == 1)
        goto LAB10;

LAB11:    xsi_set_current_line(44, ng0);
    t2 = (t0 + 2232U);
    t3 = *((char **)t2);
    t2 = (t0 + 4232);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 32, 0LL);
    goto LAB8;

LAB10:    t29 = *((unsigned int *)t13);
    t30 = *((unsigned int *)t14);
    t31 = (t29 - t30);
    t32 = (t31 + 1);
    xsi_vlogvar_wait_assign_value(t11, t12, 0, *((unsigned int *)t14), t32, 0LL);
    goto LAB11;

}


extern void work_m_00000000004165586116_2381739659_init()
{
	static char *pe[] = {(void *)Cont_21_0,(void *)Cont_29_1,(void *)Initial_31_2,(void *)Always_41_3};
	static char *se[] = {(void *)sp_dump};
	xsi_register_didat("work_m_00000000004165586116_2381739659", "isim/test_mips_isim_beh.exe.sim/work/m_00000000004165586116_2381739659.didat");
	xsi_register_executes(pe);
	xsi_register_subprogram_executes(se);
}
