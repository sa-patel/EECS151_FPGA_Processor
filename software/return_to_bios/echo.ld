SECTIONS
{
    . = 0x10000500;
    .text : {
        * (.start);
        * (.text);
    }
}
