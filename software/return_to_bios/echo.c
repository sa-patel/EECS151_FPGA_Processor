#include "types.h"
typedef void (*entry_t)(void);

int main(void)
{
    uint32_t bios = 1073741824;
    entry_t start = (entry_t) (bios);
    start();
    return 0;
}
