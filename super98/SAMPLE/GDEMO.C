/*====================================================
	PC9801 Graphic Library - Demonstration Program
	GDEMO.C
	1992/02/17  by ZOBplus Neopara
    �����^�C�v��PC9801�ł͓��삵�܂���
====================================================*/

#include <stdio.h>
#include <stdlib.h>
#include "super98.h"

#define FLAMEW		14		/* �E�C���h�E�̘g�̕� */
#define BOLDKANJI	0x10	/* KanjiGputc()�ő������w�肷��r�b�g */

/*�F�̒萔�W��*/
enum {
	BLACK, GRAY1, GRAY2, GRAY3, BLUE1, BLUE2, RED1, RED2,
	GREEN1, GREEN2, CYAN1, CYAN2, YELLOW1, YELLOW2, BROWN, WHITE
};

/*�J���[�R�[�h�̃e�[�u��*/
static unsigned int paltable[] = {
	0x000, 0xDCC, 0xA99, 0x555, 0x37D, 0x126, 0x4C0, 0x290,
	0xA45, 0x834, 0xA7F, 0x85D, 0xAD3, 0x8C1, 0x451, 0xFFF
};


/*---------------------------------------------------------------------
	�p���b�g�̃t�F�[�h�C��/�t�F�[�h�A�E�g
	- PaletteAll()���g�p -
	IN : unsigned int paltable[] �J���[�R�[�h�̃e�[�u��(�O���[�o��)
	     int vec ���Ȃ�t�F�[�h�C���A�����łłȂ���΃t�F�[�h�A�E�g
---------------------------------------------------------------------*/

void SetUpPalette(int vec)
{
	unsigned int tmppal[16];
	unsigned int level, tone, col, b, r, g;

	for (level=0 ; level<=16 ; level++) {
		tone = (vec>0) ? level : 16-level;
		for (col=0 ; col<16 ; col++) {
			b = (paltable[col] & 0xF)*tone >> 4;
			r = ((paltable[col]>>4) & 0xF)*tone >> 4;
			g = ((paltable[col]>>8) & 0xF)*tone >> 4;
			tmppal[col] = (g<<8)|(r<<4)|b;  /* ����i�K�̃J���[�R�[�h�𓾂� */
		}
		PaletteAll(tmppal);
	}
}


/*----------------------------------------------------
	�E�C���h�E(���h�L)�̕\��
	- GdcLine(), GdcBox(), GraphicBoxf()���g�p -
	IN : unsigned int sx,sy �E�C���h�E����[���W
	     unsigned int ex,ey �E�C���h�E�E���[���W
	     unsigned int col ������h��Ԃ��F�̔ԍ�
----------------------------------------------------*/

void DrawWindow(unsigned int sx, unsigned int sy,
				unsigned int ex, unsigned int ey, unsigned int col)
{
	GdcBox(sx,sy,ex,ey,GRAY3);
	GraphicBoxf(sx+1,sy+1,ex-1,ey-1,WHITE);
	GraphicBoxf(sx+4,sy+4,ex-4,ey-4,GRAY1);
	GraphicBoxf(sx+FLAMEW,sy+FLAMEW,ex-FLAMEW,ey-FLAMEW,col);
	GdcLine(sx+1,ey-1,ex-1,ey-1,GRAY2);
	GdcLine(sx+2,ey-2,ex-2,ey-2,GRAY2);
	GdcLine(sx+3,ey-3,ex-3,ey-3,GRAY2);
	GdcLine(ex-1,sy+1,ex-1,ey-1,GRAY2);
	GdcLine(ex-2,sy+2,ex-2,ey-2,GRAY2);
	GdcLine(ex-3,sy+3,ex-3,ey-3,GRAY2);
	GdcLine(sx+(FLAMEW-1),ey-(FLAMEW-1),ex-(FLAMEW-1),ey-(FLAMEW-1),WHITE);
	GdcLine(ex-(FLAMEW-1),sy+(FLAMEW-1),ex-(FLAMEW-1),ey-(FLAMEW-1),WHITE);
	GdcLine(sx+(FLAMEW-1),sy+(FLAMEW-1),ex-(FLAMEW-1),sy+(FLAMEW-1),GRAY2);
	GdcLine(sx+(FLAMEW-1),sy+(FLAMEW-1),sx+(FLAMEW-1),ey-(FLAMEW-1),GRAY2);
}


/*-----------------------------------------------------------
	�^�C����ɃE�C���h�E��\��
	IN : unsigned int xp,yp ��/�c�����̃E�C���h�E�̕�����
	     unsigned int col ������h��Ԃ��F�̔ԍ�
-----------------------------------------------------------*/

void DrawTilingWindows(unsigned int xp, unsigned int yp, unsigned int col)
{
	unsigned int winx, winy, x, y;
	unsigned int boxw = 640/xp;
	unsigned int boxh = 400/yp;

	for (winy=0 ; winy<yp ; winy++)
		for (winx=0 ; winx<xp ; winx++) {
			x = winx*boxw;
			y = winy*boxh;
			DrawWindow(x,y,x+boxw-1,y+boxh-1,col);
		}
}


/*---------------------------------------------------------
	���x�����[�^���̕\��
	- GraphicBoxf()���g�p -
	IN : unsigned int bars ���ɗ�ׂ郁�[�^�̐�
	     unsigned int maxlvl �e���[�^�̍ő�l(�ڐ��̐�)
	     unsigned int count �\����
---------------------------------------------------------*/

void LevelMeter(unsigned int bars, unsigned int maxlev, unsigned int count)
{
	int level[32], lev, vec;
	unsigned int bar, col, x, y;
	unsigned int i;

	unsigned int redlev = maxlev*9/10;
	unsigned int yellev = maxlev*7/10;
	unsigned int boxw = 640/bars*9/10-1;
	unsigned int boxh = 400/maxlev*9/10-1;

	for (bar=0 ; bar<bars ; bar++)
		level[bar] = 0;

	for (i=0 ; i<count ; i++) {
		do {
			bar = rand() % bars;
			vec = (rand() % 2)*2 - 1;  /* vec= -1 or +1 */
			lev = level[bar] + vec;
		} while (lev<0 || lev>maxlev);
		if (vec<0)
			col = BLUE2;
		else {
			level[bar]++;
			if (lev>=redlev)
				col = RED1;
			else if (lev>=yellev)
				col = YELLOW1;
			else
				col = CYAN1;
		}
		x = bar*640/bars;
		y = 400-level[bar]*400/maxlev;
		GraphicBoxf(x,y,x+boxw,y+boxh,col);
		if (vec<0)
			level[bar]--;
	}
}


/*--------------------------------------
	�l�p�`�Ɖ~�̕`��
	- GdcLine(), GdcCircle()���g�p -
	IN : unsigned int count �`���
--------------------------------------*/

#define MAXR 80  /* �}�`�̒��S����[�܂ł̋����̍ő�l */

void DrawSquaresAndCircles(unsigned int count)
{
	unsigned int x, y, r, col0, col;
	unsigned int i;

	for (i=0 ; i<count ; i++) {
		x = rand()%(320-FLAMEW*2-MAXR*2)+FLAMEW+MAXR;
		y = rand()%(400-FLAMEW*2-MAXR*2)+FLAMEW+MAXR;
		col0 = (rand()%6)*2+GRAY2;
		for (r = rand()%MAXR+1 ; r>0 ; r--) {
			col = col0+rand()%2;
			GdcLine(x+r,y,x,y-r,col);
			GdcLine(x,y-r,x-r,y,col);
			GdcLine(x-r,y,x,y+r,col);
			GdcLine(x,y+r,x+r,y,col);
			GdcCircle(x+320,y,r,col);
		}
	}
}


/*----------------------------------------------------
	�O���t�B�b�N�����������\��
	- KanjiGputc()���g�p -
	IN : char *s ����������
	     unsigned int x,y �ŏ��̕����̍���[�̍��W
	     unsigned int col �����̐F�ԍ�
----------------------------------------------------*/

void KanjiGputs(char *s, unsigned int x, unsigned int y, unsigned int col)
{
	unsigned int kanji;

	while (*s) {
		kanji = (*s) + ((*(s+1))<<8);  /*��ʃo�C�g�E���ʃo�C�g������*/
		KanjiGputc(kanji,x,y,col);
		x += 16;
		s += 2;
	}
}


/*--------------------------------------------
	�l���n��(�Ȃ�)���O���t�B�b�N��ʂɕ\��
--------------------------------------------*/

void WriteKanji()
{
	unsigned int wc, wx, wy, col;
	static char *words[] = {
		"������|","�����ɐ�","�O��s�o","�V������","���S����",
		"���w����","��������","�ꝺ���","�Ɠ����S","�l�{���Q",
		"�i�s����","�ːF����","�ē���H","�D�_�s�f","��������",
		"�_�o�S�v","���˖Ґi","���C����","��r����","���]���|",
		"��q����","���i�F��","��̐▽","�������","��萬�A"
	};

	wc = 0;
	for (wy=0 ; wy<5 ; wy++)
		for (wx=0 ; wx<5 ; wx++) {
			col = (wx*2+BLUE1) | ((wx+wy)%2 ? BOLDKANJI : 0);
			KanjiGputs(words[wc],wx*128+32,wy*80+31,BLACK);
			KanjiGputs(words[wc],wx*128+32,wy*80+32,col);
			wc++;
		}
}


/*---------------------------------------------------------------------
	15�p�Y�����̋�`�̈�̈ړ��Ɖ�ʃX�N���[��
	- GraphicMove(), GdcScroll()�����g�p -
	IN : unsigned int xp,yp ��/�c�����̗̈�̕�����
	     unsigned int *initx,*inity �X�y�[�X�̏����ʒu (�I�����X�V�����)
	     unsigned int col �X�y�[�X�̐F�ԍ�
	     int scrl ��ʑS�̂��X�N���[�����鎞�̃��C����
	     unsigned int count �X�y�[�X�̈ړ���
---------------------------------------------------------------------*/

void SlideRectangles(unsigned int xp, unsigned int yp,
					 unsigned int *initx, unsigned int *inity,
					 unsigned int col, int scrl, unsigned int count)
{
	unsigned int spacex, spacey, rects, steps, x, y, wx, wy;
	int dx, dy, newx, newy;
	unsigned int i;

	unsigned int boxw = 640/xp;
	unsigned int boxh = 400/yp;

	/* �X�y�[�X����� */
	for (spacey=0 ; spacey<yp ; spacey++)
		for (spacex=0 ; spacex<xp ; spacex++) {
			x = spacex*boxw;
			y = spacey*boxh;
			if (*initx==spacex && *inity==spacey)
				GraphicBoxf(x,y,x+boxw-1,y+boxh-1,col);
			else
				GdcBox(x,y,x+boxw-1,y+boxh-1,col);
		}
	spacex = *initx;
	spacey = *inity;

	/* ��`�̈�̈ړ� */
	for (i=0 ; i<count ; i++) {
		/* �X�y�[�X�̈ړ���ƁA�ړ�����̈�̌��̌��� */
		do {
			dx = (rand()%2)*2-1;  /* dx  = -1 or +1 */
			if (i%2) {
				dy = 0;
				rects = rand()%(xp-1)+1;
				steps = boxw;
			} else {
				dy = dx;
				dx = 0;
				rects = rand()%(yp-1)+1;
				steps = boxh;
			}
			newx = spacex+dx*rects;
			newy = spacey+dy*rects;
		} while (newx<0 || newy<0 || newx>=xp || newy>=yp);
		/* �ړ�����̈�S�̂̍�����W�Ƒ傫���̌v�Z */
		x = (dx>0) ? (spacex+1)*boxw : newx*boxw;
		y = (dy>0) ? (spacey+1)*boxh : newy*boxh;
		wx = (0==dx) ? boxw : boxw*rects;
		wy = (0==dy) ? boxh : boxh*rects;
		/* �ړ� */
		while (steps) {
			GraphicMove(x,y,x+wx-1,y+wy-1,x-dx,y-dy);
			if (scrl)
				GdcScroll(scrl);  /* ��ʃX�N���[�� */
			x -= dx;
			y -= dy;
			steps--;
		}
		spacex = newx;
		spacey = newy;
	}

	/* �X�y�[�X�̈ʒu���X�V */
	*initx = spacex;
	*inity = spacey;
}


/*--------------------
	���C�����[�`��
--------------------*/

void main(void)
{
	unsigned int spacex, spacey;
	char far *gr_work;

	GraphicInit(1,1);
	SetPen(0xFFFF,3); 
	GraphicCls(BLACK);
	SetUpPalette(-1);
	puts("\33[>1h\33[>5h\33*");  /* �t�@���N�V�����L�[/�J�[�\��/��ʏ��� */

	GraphicCls(BLUE2);
	SetUpPalette(+1);
	LevelMeter(8,16,20000);
	GraphicCls(BLUE2);
	LevelMeter(32,50,60000U);
	SetUpPalette(-1);

	DrawTilingWindows(2,1,BROWN);
	SetUpPalette(+1);
	DrawSquaresAndCircles(200);
	SetUpPalette(-1);

	DrawTilingWindows(5,5,GRAY3);
	WriteKanji();
	SetUpPalette(+1);
	gr_work = (char far*)0x0000054D;	
	if (*gr_work & 0x40) { 
		spacex = spacey = 2;
		SlideRectangles(5,5,&spacex,&spacey,BROWN,0,30);
		SlideRectangles(5,5,&spacex,&spacey,BROWN,+1,6);
		SlideRectangles(5,5,&spacex,&spacey,BROWN,-1,6);
		spacex = spacey = 0;
		SlideRectangles(10,10,&spacex,&spacey,BLUE2,+5,20);
		SetUpPalette(-1);
	} else {
		puts("���̃}�V����EGC�����ڂ���Ă��Ȃ��̂ňȉ��̃f�����I�����܂�\n");
	}
	
	GraphicCls(BLACK);
	PaletteInit();
	puts("\33[>1l\33[>5l");  /* �t�@���N�V�����L�[/�J�[�\���\�� */
}