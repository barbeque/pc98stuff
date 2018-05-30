/***************************************************************
PC-9821 Enhanced Graphics (256Color Packed Pixel)
VRAM Linear Access  Sample Program
                                   for Watcom C++ 11.0J & DOS4GW
                                       gcc ( DJGPP V2.01 )
                                         2002/09/22 By DULL
****************************************************************/
#include <stdio.h>
#include <dos.h>
#include <conio.h>

#ifdef __GNUC__
 #include <go32.h>
 #include <dpmi.h>
 #include <sys/farptr.h>
#endif

#define _16MB_CHECK_ 1
#define _HSYNC_ 0


typedef struct DPMI_MEM_{
	unsigned int selecter;
	unsigned int p_address;		// Physical Address
	unsigned int p_size;		// Physical Address Size
	unsigned int l_address;		// Linear Address
}DPMI_MEM;


#if _HSYNC_
static int Hmode;
#endif


/************************************************************************************/
#ifdef __WATCOMC__
// gcc emulation ?

#define _farpokeb(x,y,z) (*((char *)y) = z)

typedef struct __dpmi_meminfo__{
	unsigned long handle;
	unsigned long size;
	unsigned long address;
}__dpmi_meminfo;


typedef union X_{
	struct{
		unsigned short l;
		unsigned short h;
	}w;
	unsigned long x;
}X;

int	__dpmi_allocate_ldt_descriptors(int _count)
{
	union REGS r;

	// �E�f�B�X�N���v�^�̊��蓖��
	r.x.eax = 0x0000;		// DPMI Function
	r.x.ecx = _count;		// �A���P�[�g����f�B�X�N���v�^�̐�
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		return(0);		// Failed
	}
	return(r.x.eax);
}

int	__dpmi_physical_address_mapping(__dpmi_meminfo *_info)
{
	union REGS r;
	X tmp;

	// �E�����A�h���X�̃}�b�s���O
	r.x.eax = 0x0800;		// DPMI Function
	tmp.x = _info->address;	// BX:CX = �������̕����A�h���X
	r.x.ebx = tmp.w.h;
	r.x.ecx = tmp.w.l;
	tmp.x = _info->size;	// SI:DI = �}�b�v����̈�̃o�C�g��
	r.x.esi = tmp.w.h;
	r.x.edi = tmp.w.l;
	int386(0x31, &r, &r);
	if( r.x.cflag ){
		return(1);			// Failed
	}
	// physical address mapping -> Linear Address
	tmp.w.h = r.x.ebx;
	tmp.w.l = r.x.ecx;
	_info->handle = tmp.x;

	return(0);
}

int	__dpmi_set_segment_base_address(int _selector, unsigned long _address)
{
	union REGS r;
	X tmp;

	// �E�Z�O�����g�̃x�[�X�A�h���X��ݒ�
	r.x.eax = 0x0007;		// DPMI Function
	r.x.ebx = _selector;	// �Z���N�^
	// CX:DX = �Z�O�����g�ɑ΂���V����32�r�b�g���j�A�x�[�X�A�h���X
	tmp.x = _address;
	r.x.ecx = tmp.w.h;
	r.x.edx = tmp.w.l;
	int386(0x31, &r, &r);

	return(r.x.cflag);
}

int	__dpmi_set_segment_limit(int _selector, unsigned long _limit)
{
	union REGS r;
	X tmp;

	r.x.eax = 0x0008;		// DPMI Function
	r.x.ebx = _selector;	// �Z���N�^
	tmp.x = _limit;			// ���~�b�g�T�C�Y
	r.x.ecx = tmp.w.h;
	r.x.edx = tmp.w.l;
	int386(0x31, &r, &r);

	return(r.x.cflag);
}

int	__dpmi_free_ldt_descriptor(int _descriptor)
{
	union REGS r;

	r.x.eax = 0x0001;		// DPMI Function
	r.x.ebx = _descriptor;
	int386(0x31, &r, &r);
	return(r.x.cflag);
}

int	__dpmi_free_physical_address_mapping(__dpmi_meminfo *_info)
{
	union REGS r;
	X tmp;

	r.x.eax = 0x0801;		// DPMI Function
	tmp.x = _info->address;	// BX:CX = �������̕����A�h���X
	r.x.ebx = tmp.w.h;
	r.x.ecx = tmp.w.l;

	int386(0x31, &r, &r);
	return(r.x.cflag);
}

#endif
/************************************************************************************/

void setpal(int no,int red,int green,int blue)
{
	outp(0xa8,no);
	outp(0xaa,green);
	outp(0xac,red);
	outp(0xae,blue);
}

void pc9821_on()
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
	__dpmi_meminfo info;

	info.handle = dm->l_address;
	info.size = dm->p_size;
	info.address = dm->p_address;

	if(dm->selecter != 0xFFFFFFFF){
		__dpmi_free_ldt_descriptor(dm->selecter);
	}

	if(dm->l_address != 0xFFFFFFFF){
		__dpmi_free_physical_address_mapping(&info);
	}
}

int dpmi_vram_on(DPMI_MEM *dm)
{
	union REGS r;
	X tmp;
	__dpmi_meminfo info;

	info.handle = 0;
	info.size = dm->p_size;
	info.address = dm->p_address;

	// �f�B�X�N���v�^�̊��蓖��
	dm->selecter = __dpmi_allocate_ldt_descriptors(1);

	// �����A�h���X�̃}�b�s���O
	__dpmi_physical_address_mapping(&info);
	dm->l_address = info.handle;

	// �Z�O�����g�̃x�[�X�A�h���X��ݒ�
//	__dpmi_set_segment_base_address(dm->selecter, );

	return(1);
}


void main()
{
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

//	pc9821_on();
	ret = dpmi_vram_on(&dm);

	if( ret ){


	}

	dpmi_vram_off(&dm);
//	pc9821_off();
}