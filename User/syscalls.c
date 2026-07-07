/******************************************************************************
 * syscalls.c
 * 为 ARM GCC (newlib-nano) 提供空的系统调用桩函数
 * 消除链接时 "_xxx is not implemented and will always fail" 警告
 ******************************************************************************/

#include <sys/stat.h>
#include <errno.h>
#include "stm32f10x.h"

#undef errno
extern int errno;

/* 关闭文件 */
int _close(int file)
{
    (void)file;
    return -1;
}

/* 退出程序 */
void _exit(int status)
{
    (void)status;
    while (1) {}
}

/* 通过文件描述符分配内存 */
int _fstat(int file, struct stat *st)
{
    (void)file;
    st->st_mode = S_IFCHR;
    return 0;
}

/* 获取进程ID */
int _getpid(void)
{
    return 1;
}

/* 查询是否存在终端 */
int _isatty(int file)
{
    (void)file;
    return 1;
}

/* 杀掉进程 */
int _kill(int pid, int sig)
{
    (void)pid;
    (void)sig;
    errno = EINVAL;
    return -1;
}

/* 设置文件位置 */
off_t _lseek(int file, off_t ptr, int dir)
{
    (void)file;
    (void)ptr;
    (void)dir;
    return 0;
}

/* 打开文件 */
int _open(const char *name, int flags, int mode)
{
    (void)name;
    (void)flags;
    (void)mode;
    return -1;
}

/* 读取数据 */
int _read(int file, char *ptr, int len)
{
    (void)file;
    (void)ptr;
    (void)len;
    return 0;
}

/* 增加程序数据指针 */
void *_sbrk(int incr)
{
    extern char __bss_end;      // 定义在链接脚本中
    static char *heap_end;
    char *prev_heap_end;

    if (heap_end == 0)
        heap_end = &__bss_end;

    prev_heap_end = heap_end;
    heap_end += incr;
    return (void *)prev_heap_end;
}

/* 写入数据 - 通过 USART1 输出 */
int _write(int file, char *ptr, int len)
{
    int i;
    (void)file;
    for (i = 0; i < len; i++)
    {
        while (!(USART1->SR & USART_SR_TXE));   /* 等待发送寄存器空 */
        USART1->DR = ptr[i];                     /* 发送一个字符 */
    }
    return len;
}
