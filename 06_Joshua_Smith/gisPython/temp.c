#include <stdlib.h>

main(void){
unsigned char GetKey(void)
{	unsigned char KeyMask[16] =
{ 0xEE, 0xDE, 0xBE, 0x7E,
0XED, 0xDD, 0xBD, 0x7D,
0xEB, 0xDB, 0xBB, 0x7B,
0xE7, 0xD7, 0xB7, 0x77
};
int i;
char Key;

for (Key=0, i=0; i<16; i++)
{	PTH = KeyMask[i];
if (PTH == KeyMask[i])
{ if (i<10) Key = ‘0’ + i;
else Key = ‘A’+ i - 10;
return (Key);
}
}
PTH = 0x0F;
return (Key);
}
}