/* void PutStrVram(int colum, int line, char *str) */
/* ----------------------------------------------- */
/* colum: ��ʏ�̌��ʒu���w�肷��B */
/* line:  ��ʏ�̍s�ʒu���w�肷��B */
/* str:   �\�����镶������w�肷��B */

extern void PutVram(int,int,unsigned int);
extern unsigned int ToJis(unsigned int);

void PutStrVram(int colum,int line,char *str)
{
    unsigned int ch;

    while ((ch = *str) != '\0') {
        ch &= 0xff;
        str++;
        if ((0x81 <= ch && ch <= 0x9f) || (0xe0 <= ch && ch <= 0xef)) {
            if (*str == '\0') {
                break;
            }
            PutVram(colum,line,ToJis((ch << 8) + (0xff & *str)));
            str++;
            colum += 2;
        }
        else {
            PutVram(colum,line,ch);
            colum++;
        }
    }
}