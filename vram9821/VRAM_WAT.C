/***************************************************************
PC-9821 Enhanced Graphics (256Color Packed Pixel)
VRAM Linear Access  Sample Program
                                   for Watcom C++ & DOS4GW
                                         2002/09/22 By DULL
****************************************************************/
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include <dos.h>
#include <conio.h>

#define _16MB_CHECK_ 1
#define _HSYNC_ 0

#define WIDTH 640
#define HEIGHT 400
#define VRAM_SIZE (WIDTH * HEIGHT)

typedef union X_{
	struct{
		unsigned short l;
		unsigned short h;
	}w;
	unsigned long x;
}X;

typedef struct DPMI_MEM_{
	unsigned int selecter;
	unsigned int p_address;		// Physical Address
	unsigned int p_size;		// Physical Address Size
	unsigned int l_address;		// Linear Address
}DPMI_MEM;

#if _HSYNC_
static int Hmode;
#endif


void setpal(int no,int red,int green,int blue)
{
	outp(0xa8,no);
	outp(0xaa,green);
	outp(0xac,red);
	outp(0xae,blue);
}

void pc9821_on(void)
{
#if _HSYNC_
	// HSYNC -> 31.47 KHz 
	if( (inp(0x09a8) & 0x01) == 0){
		outp(0x09a8,0x01);
		Hmode = 1;
	}
#endif

	// 256 color mode
	outp(0x6a,0x07);
	outp(0x6a,0x21);
	outp(0x6a,0x06);

	// Packed Pixel
	*((char *)0xe0100) = 0x00;

	// 16[MB] System Area -> VRAM ON
	*((char *)0xe0102) = 0x01;

	// Graphics Start
	outp(0xa2,0x0d);
}

void pc9821_off()
{
	// 16[MB] System Area -> VRAM OFF
	*((char *)0xe0102) = 0x00;

	// 16 Color (standard) mode
	outp(0x6a,0x07);
	outp(0x6a,0x20);
	outp(0x6a,0x06);

#if _HSYNC_
	// HSYNC -> 24.8? KHz
	if(Hmode==1)
		outp(0x09a8,0x00);
#endif

	// TEXT Start
	outp(0x62,0x0d);

}

void dpmi_vram_off(DPMI_MEM *dm)
{
	union REGS r;
	X tmp;

	if(dm->selecter != 0xFFFFFFFF){
		r.x.eax = 0x0001;		// DPMI Function
		r.x.ebx = dm->selecter;
		int386(0x31, &r, &r);
		if( r.x.cflag ){
			// Failed
			puts("�f�B�X�N���v�^���J���ł��܂���ł����B");
		}
	}

	if(dm->l_address != 0xFFFFFFFF){
		r.x.eax = 0x0801;		// DPMI Function
		tmp.x = dm->l_address;	// BX:CX = �������̕����A�h���X
		r.x.ebx = tmp.w.h;
		r.x.ecx = tmp.w.l;

		int386(0x31, &r, &r);
		if( r.x.cflag ){
			// Failed
			puts("�����A�h���X�̃}�b�s���O�̉������ł��܂���ł����B");
		}
	}
}

int dpmi_vram_on(DPMI_MEM *dm)
{
	union REGS r;
	X tmp;

	// �E�f�B�X�N���v�^�̊��蓖��
	r.x.eax = 0x0000;		// DPMI Function
	r.x.ecx = 1;			// �A���P�[�g����f�B�X�N���v�^�̐�
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		// Failed
		puts("�f�B�X�N���v�^���A���P�[�g�ł��܂���ł����B");
		return(0);
	}
	// �A���P�[�g���ꂽ�Z���N�^
	dm->selecter = r.x.eax;


	// �E�����A�h���X�̃}�b�s���O
	r.x.eax = 0x0800;		// DPMI Function
	tmp.x = dm->p_address;	// BX:CX = �������̕����A�h���X
	r.x.ebx = tmp.w.h;
	r.x.ecx = tmp.w.l;
	tmp.x = dm->p_size;		// SI:DI = �}�b�v����̈�̃o�C�g��
	r.x.esi = tmp.w.h;
	r.x.edi = tmp.w.l;
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		// Failed
		puts("�����A�h���X���}�b�s���O�ł��܂���ł����B");
		return(0);
	}
	// physical address mapping -> Linear Address
	tmp.w.h = r.x.ebx;
	tmp.w.l = r.x.ecx;
	dm->l_address = tmp.x;


	// �E�Z�O�����g�̃x�[�X�A�h���X��ݒ�
	r.x.eax = 0x0007;		// DPMI Function
	r.x.ebx = dm->selecter;		// �Z���N�^
	// CX:DX = �Z�O�����g�ɑ΂���V����32�r�b�g���j�A�x�[�X�A�h���X
	r.x.ecx = tmp.w.h;
	r.x.edx = tmp.w.l;
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		// Failed
		puts("�x�[�X�A�h���X��ݒ�ł��܂���ł����B");
		return(0);
	}
/*
	// �E�Z�O�����g�̃��~�b�g��ݒ�
	r.x.eax = 0x0008;		// DPMI Function
	r.x.ebx = dm->selecter;		// �Z���N�^
	tmp.x = dm->p_size;		// ���~�b�g�T�C�Y
	r.x.ecx = tmp.w.h;
	r.x.edx = tmp.w.l;
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		// Failed
		puts("���~�b�g��ݒ�ł��܂���ł����B");
		return(0);
	}
*/
	return(1);
}

int get_ds(void)
{
#if 1
	unsigned short ds_sreg;

	_asm{
		mov ax,ds
		mov [ds_sreg],ax
	}
	return(ds_sreg);
#else
    struct SREGS sregs;

    segread( &sregs );
	return(sregs.ds);
#endif
}

/********************************************************************/

void main()
{
	unsigned char *VVRAM;
	int i,x,y,dat,my_ds;
	unsigned char tp1,tp2,tp3,tp4;
	unsigned char p1,p2,p3,p4;
	unsigned char WTable[256];
	float palk;
	int ret;
	DPMI_MEM dm;


#if _16MB_CHECK_
	if( (inp(0x043b)&0x04) ){
		puts("16MB�V�X�e����Ԃ̐ݒ��ύX���ĉ������B");
		return;
	}
#endif

	memset(&dm,0,sizeof(DPMI_MEM));
	dm.selecter  = 0xFFFFFFFF;
	dm.p_address = 0x00F00000;	// 16[MB] System Area
	dm.p_size    = 0x00080000;	// VRAM 512[KB]
	dm.l_address = 0xFFFFFFFF;

	pc9821_on();
	ret = dpmi_vram_on(&dm);
	my_ds = get_ds();

	if( ret ){
		VVRAM = (unsigned char *)malloc(VRAM_SIZE);
		p1 = p2 = p3 = p4 = 0;

		// �e�[�u���̍쐬 - ���s���x���グ�邽�ߍŏ��Ɍv�Z���Ă����B
		for(i=0;i<256;i++){
			palk=30.0*(1.0+sin(i*2.0*3.141592654/256.0));
			WTable[i]=(unsigned char)palk;
		}

		// �p���b�g�̐ݒ�
		for(i=0;i<256;i++)
			setpal(i,i,10,100-i/3);

//		while(kbhit()==0){
		for(i=0;i<100;i++){		// 100�t���[���`��ŏI���B
			tp1 = p1;
			tp2 = p2;
			for(x=0;x<WIDTH;x++){
				tp3 = p3;
				tp4 = p4;
				for(y=0;y<HEIGHT;y++){
					dat = WTable[tp1]+WTable[tp2]+WTable[tp3]+WTable[tp4];
					VVRAM[x + y * WIDTH] = dat;
					tp3 += 1;
					tp4 += 3;
				}
				tp1 += 2;
				tp2 += 1;
			}
			p1 += 1;
			p2 -= 2;
			p3 += 3;
			p4 -= 4;
#if 0
			// gcc �͂��������ȁH
			movedata(my_ds,(unsigned int)VVRAM,
					dm.selecter,0,VRAM_SIZE);
#else
			// DOS4GW �ł̓��j�A�A�h���X���w��̓]�����\�B
			memcpy((void *)dm.l_address,VVRAM,VRAM_SIZE);
#endif
		}

		// clear !!
		memset(VVRAM,0,640*400);
		memcpy((void *)dm.l_address,VVRAM,VRAM_SIZE);

		free(VVRAM);
	}

	dpmi_vram_off(&dm);
	pc9821_off();
}
