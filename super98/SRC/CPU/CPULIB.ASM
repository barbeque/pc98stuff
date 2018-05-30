TITLE CPU

		.8086
		.MODEL	SMALL,C

		.CODE


;==========
;int CpuKind(void);
;���́F�Ȃ�
;�o�́F 0=8086
;       1=80186
;       2=80286
;       3=80386
;       4=80486
;      11=V30�EV50�EV33A
;      31=V33
;      83=80386(V86)
;      84=80486(V86)
;==========

cpuis86  =  0H
cpuis186 =  1H
cpuis286 =  2H
cpuis386 =  3H
cpuis486 =  4H
cpuisV30 = 11H
cpuisV33 = 31H

		PUBLIC	CpuKind
CpuKind		PROC	NEAR
;--- 8086,80186,V30,V33(A),V50 / 80286,386,486 ����
		pushf			;mov ax,FLAGS
		pop	ax
		test	ax,8000H	;FLAGS��MSB���`�F�b�N
		jnz	chk186				;MSB = 1
;--- 80286 / 8086,80186,V30,V33(A),V50,386,486 ����
chk286:		pushf			;�t���O�Ҕ�
		mov	ax,4000H	;FLAGS��bit 12=1����������
		push	ax		;mov FLAGS,ax
		popf
		pushf			;mov ax,FLAGS
		pop	ax
		popf			;�t���O���A
		test	ax,4000H	;FLAGS��bit 12���`�F�b�N
		mov	al,cpuis286
		jz	DoneCheckCpu
;--- 386 / 486 ����
;    386,486�ȊO�Ŏ��s�����Ă͂Ȃ�Ȃ��B
;�S�W�U�ł̓���͖��m�F
	.386
		pushfd			;EFLAGS�Ҕ�
		push	bp		;�A���C�������g�`�F�b�N���N�����Ȃ�
		mov	bp,sp		;�悤�ɃX�^�b�N�|�C���^��32bit���E��
		and	sp,0FFFCH	;����
		pushfd			;mov eax,EFLAGS
		pop	eax
		or	eax,00040000H	;bit18=1(Alignment Check ON)
		push	eax		;mov EFLAGS,eax
		popfd
		pushfd			;mov eax,EFLAGS
		pop	eax
		mov	sp,bp		;�X�^�b�N�|�C���^�����ɖ߂�
		pop	bp
		popfd			;EFLAGS���A
		test	eax,00040000H	;EFLAGS��bit 18���`�F�b�N
	.8086
		mov	al,cpuis486
		jnz	chkV86
		mov	al,cpuis386
		jmp	chkV86
;--- 8086,V30,V33(A),V50 / 80186,80286,386,486 ����
chk186:		mov	al,01H		;��V�t�g�l
		mov	cl,20H		;�V�t�g�񐔁i�R�Q��j
		shr	al,cl
		or	al,al
		mov	al,cpuis186
		jnz	DoneCheckCpu
;--- V30,V50,V33A / 8086,80186,80286,386,486,V33 ����
		mov	ax,0100H	;��ϊ��l
	DB	0D5H,00H
	;80x86  : AAD 00 --> AL=AH*00H+AL, AH=00
	;V30,50 : AAD    --> AL=AH*0AH+AL, AH=00
		mov	ax,cpuisV30
		jnz	DoneCheckCpu
;--- 8086,80186,V30,V50,V33A / V33,80286,386,486 ����
		push	sp
		pop	ax
		cmp	ax,sp
		mov	ax,cpuisV33
		je	DoneCheckCpu
		mov	ax,cpuis86
		jmp	DoneCheckCpu
;--- Real Mode / V86 Mode ����
chkV86:
	.286P
		smsw	bx	;mov ax,MSW(CR0)
		test	bl,1	;MSW��bit 0(Protect Mode Flag)���`�F�b�N
		jz	DoneCheckCpu	;PMF=0
		or	al,80H	;PMF=1
	.8086
DoneCheckCpu:	mov	ah,00H
		ret
CpuKind		ENDP


;==========
;int GetSysClk(void);
;���́F�Ȃ�
;�o�́F0 = 10MHz�n�C1 = 8MHz�n
;==========
		PUBLIC	GetSysClk
GetSysClk	PROC	NEAR
		push	es
		mov	ax,0000H
		mov	es,ax			;ES��Low Memory Segment
		mov	ax,es:[0500H]		;AX��[0000:0500]
		pop	es
		and	ax,8000H		;bit 15���c���ă}�X�N
		rol	ax,1			;bit 15��bit 0�Ɉړ�
		ret
GetSysClk	ENDP


;==========
;void CpuReset(void);
;�b�o�t���\�t�g�E�F�A���烊�Z�b�g����
;==========
CpuReset	PROC	NEAR
;--- �O�������֎~
;�@�@�^�C�}�Ȃǂ����삵�Ă���Ƃ��A�C�j�V�����C�Y�����̓r���Ŋ�����
;�@�@������ƌ듮�삷��\��������̂ŁA�����h���B
		cli
;--- 80286/386/486���ڋ@��̂��߂̏���
		mov	al,0FH		;SHUT0=1
		out	37H,al
		mov	al,0BH		;SHUT1=1
		out	37H,al
;--- ����b�o�t����
;    VM21��OUT F0H,00H���s���ƃn���O����̂ŁA�����������邽��
;    V30�̂Ƃ���OUT F0H���X�L�b�v����
		pushf
		pop	ax
		test	ax,8000H
		jnz	JumpFFFF
;--- �b�o�t���Z�b�g���s
;�@�@80286/386/486���ڋ@��ł�CPU RESET�|�[�g��OUT����ƁACPU��
;�@�@RESET�[�q�̂݃A�N�e�B�u�ɂȂ�B
		mov	al,0
		mov	dx,00F0H
		out	dx,al		;CPU RESET���s
		mov	cx,1000H
		loop	$		;���Z�b�g��������܂ő҂�
;--- �C�j�V�����C�Y�������[�`���ɃW�����v
;�@�@�V���b�g�_�E���E�|�[�g�������Ȃ��@��̏ꍇ�̂��߁ACPU�̃��Z�b�g����
;�@�@�߂���Ԃɂ���FFFF:0000H�ɃW�����v����B
JumpFFFF:	mov	ax,0000H
		push	ax
		popf
		mov	ds,ax
		mov	es,ax
		mov	ss,ax
		jmp	FAR PTR ResetEntry
CpuReset	ENDP


ResetSeg	SEGMENT	AT 0FFFFH
		ASSUME	cs:ResetSeg
		ORG	0000H
ResetEntry	PROC	FAR
ResetEntry	ENDP
ResetSeg	ENDS


END


���e��b�o�t���ʃ��[�`��
;--- 8086�AV30�AV33(A)�AV50�^80186�A80286�A386�A486����
;    AL��01H�A CL��20H�ƃZ�b�g���āASHR AL,CL�����s����B
;    8086��V�V���[�Y�ł�20H(32)��V�t�g���s����AL=0�ƂȂ�B
;    80186�ȏ��CPU�ł�20H and 1FH=00�ƂȂ�A�V�t�g�͍s��ꂸAL=1�ƂȂ�B
		mov	al,01H		;��V�t�g�l
		mov	cl,20H		;�V�t�g�񐔁i32��j
		shr	al,cl
		or	al,al
		jz	(8086,V30,V33,V50)	;�V�t�g���s����AL=0
		jmp	(80186,80286,386,486)	;�V�t�g�͍s��ꂸAL=1


;--- V30�EV50�EV33A�^8086�E80186�E80286�E386�E486�EV33����
;    AX��0100H���Z�b�g���āAAAD 00�����s����B
;    V�V���[�Y�i����V33�j�ł�AL��01*0AH+00=0AH�ƂȂ�B
;    80x86�EV33�ł�AL��01*00H+00=00H�ƂȂ�B
		mov	ax,0100H	;��ϊ��l
	DB	0D5H,00H
	;80x86  : AAD 00	;AL=AH*00H+AL, AH=00
	;V30    : AAD		;AL=AH*0AH+AL, AH=00
		jz	(8086,80186,80286,386,486,V33)	;0����Z�����AL=0
		jmp	(V30,V50)			;10����Z�����AL=0AH


;--- V30�AV33(A)�AV50�^8086����
;    8086�AV30�AV33(A)�AV50�ȊO��CPU�ł��̃��[�`�������s�����Ă͂Ȃ�Ȃ�
		mov	bx,sp		;�X�^�b�N�|�C���^�ۑ�
		push	cs		;POP CS�ɔ�����CS��PUSH
		mov	al,0		;adc al,0C0H�ŌJ��オ��Ȃ��悤��
		stc			;CF=1
	DB	0FH,14H,0C0H
	;V30  : set1	al,cl		;AL��bit cl��set�����,CF=no change
	;8086 :	pop	cs
	;8086 : adc	al,0C0H		;AL=0C1H�ACF=0
		mov	sp,bx		;�X�^�b�N�|�C���^���A
		jc	(V30,V33(A),V50)
		jmp	(8086)


;--- 8086�A80186�AV30�AV50�AV33A�^V33�A80286�A386�A486����
		push	sp
		pop	ax
		cmp	ax,sp
		je	(V33,80286,386,486)
		jmp	(8086,80186,V30,V50,V33A)


;--- 386�E486�^8086�E80186�E80286�EV30�EV33(A)�EV50����
;    386���߂��g�p����Ƃ��ɂ��̔��肪���p�ł���B
;    386�E486�ł�bit 15�͏��0�Abit 14�͏��������\�Ȃ̂ŁA
;    bit 14=1���������񂾂Ƃ��Abit 15,14=0,1���ǂݏo�����
;    386�E486�ł���B
		pushf
		pop	ax		;mov ax,FLAGS
		pushf			;FLAGS�Ҕ�
		or	ax,4000H	;FLAGS bit 14=1 ���Z�b�g
		push	ax
		popf			;mov FLAGS,ax
		pushf
		pop	ax		;mov ax,FLAGS
		popf			;�t���O���A
		and	ax,0C000H	;FLAGS bit 15,14 ���c���ă}�X�N
		cmp	ax,4000H	;FLAGS bit 15,14=01�Ȃ�386�ȏ�
		je	(386,486)
		jmp	(8086,80186,80286,V30,V33(A),V50)


;--- 80286�E386�E486�^8086�E80186�EV30�EV33(A)�EV50����
;    80286�E386�E486�ł�bit 15�͏��0�Ȃ̂ŁAbit 15=0��
;    �ǂݏo�����80286�E286�E486�ł���B
		pushf			;mov ax,FLAGS
		pop	ax
		test	ax,8000H	;FLAGS bit 15=0 �Ȃ� 80286�ȏ�
		jz	(80286,386,486)
		jmp	(8086,80186,V30,V33(A),V50)


;--- 80286�^8086�E80186�EV30�EV33(A)�EV50�E386�E486����
;    80286�ł�bit14�͏��0�Ȃ̂ŁAbit 14=1����������ŁA
;    0���ǂݏo�����80286�ł���B
		pushf
		pop	ax		;mov ax,FLAGS
		pushf			;�t���O�Ҕ�
		or	ax,4000H	;FLAGS bit 14=1���Z�b�g
		push	ax
		popf			;mov FLAGS,ax
		pushf
		pop	ax		;mov ax,FLAGS
		popf			;�t���O���A
		test	ax,4000H	;FLAGS bit 14=0�Ȃ�80286
		jz	(80286)
		jmp	(8086,80186,V30,V33(A),V50,386,486)


;--- 386�E486 Real Mode�^
;	386�E486 V86 Mode�E8086�E80186�E80286�EV30�EV50�EV33(A)����
;    386,486�̃��A�����[�h�ł������s�ł��Ȃ��@�\�iCRn���W�X�^���̏��������A
;    V86���[�h�ւ̈ڍs�Ȃǁj���g�p����Ƃ��ɂ��̔��肪���p�ł���B
;    386,486�̃��A�����[�h�̂�bit 13�`12�����������ł���̂ŁA�����𔽓]
;    �������l��FLAGS�ɏ������݁A�����ǂ݂����Č���FLAGS�ƈقȂ��386,486
;    ���A�����[�h�Ɣ��f�ł���B
		pushf
		pop	ax		;mov ax,FLAGS
		pushf			;�t���O�Ҕ�
		mov	bx,ax		;����FLAGS�̒l��ۑ�
		xor	ax,3000H	;FLAGS bit 13�`12=�𔽓]
		push	ax
		popf			;mov FLAGS,ax
		pushf
		pop	ax		;mov ax,FLAGS
		popf			;�t���O���A
		cmp	ax,bx		;����FLAGS�̒l�Ɣ�r
		jne	(386,486 Real Mode)
		jmp	(386,486 V86 Mode, 80286,80186,8086,V series)


;--- Real Mode�^V86 Mode����
;    80286�E386�E486�݂̂Ŏ��s���邱�ƁB
;    8086�E80186�EV30�EV33(A)�EV50�Ŏ��s�����Ă͂Ȃ�Ȃ��B
	.286P
		smsw	ax	;mov ax,MSW(CR0)
		test	al,1	;MSW��bit 0(Protect Mode Flag)���`�F�b�N
		jz	(Real Mode)	;PMF=0
		jmp	(V86 Mode)	;PMF=1


;--- 386�^486����
;    386�E486�ȊO�Ŏ��s�����Ă͂Ȃ�Ȃ��B
	.386
		mov	bx,sp		;SP�ۑ�
		and	sp,0FFFCH	;AC���N�����Ȃ��悤SP��32bit���E�ɒ���
		pushfd			;EFLAGS�Ҕ�
		cli			;�����֎~
		pushfd
		pop	eax		;mov eax,EFLAGS
		or	eax,00040000H	;bit18=1(Alignment Check ON)
		push	eax
		popfd			;mov EFLAGS,eax
		pushfd
		pop	eax		;mov eax,EFLAGS
		popfd			;EFLAGS���A
		mov	sp,bx		;SP���A
		test	eax,00040000H	;EFLAGS��bit 18���`�F�b�N
	.8086	;16bit���Ώ����W�����v���߂���������Ȃ��悤��.386������
		jnz	(486)		;bit 18=1
		jmp	(386)		;bit 18=0


;8086�EV30�EV50�EV33�Ŏ��s���Ȃ����ƁB
;���j80486�̖��߂��g���Ă��镔�������邽�߁AMASM 6.00�ȍ~�܂���TASM 2.0�ȍ~�łȂ���΃A�Z���u���ł��Ȃ��B
		push	ds
		push	es
	;--- INT 06H�x�N�^�ۑ�
		mov	ax,3506H
		int	21H		;ES:BX �� INT 06H entry
	;--- INT 06H�x�N�^�ύX
		mov	ax,cs
		mov	ds,ax
		mov	dx,OFFSET InvCodeDetect
		mov	ax,2506H
		int	21H
		cli
		mov	cx,sp		;SP�ۑ�
	;--- 80286���L���߂̃e�X�g
		mov	dx,01H
	.286P
		smsw	ax		;80186,V33A�ł͖���`
	;--- 386���L���߂̃e�X�g
		inc	dx
	.386
		bt	ax,1		;80286�ł͖���`
	;--- 486���L���߂̃e�X�g
		inc	dx
	.486
		bswap	eax		;386�ł͖���`
	.8086
		inc	dx
InvCodeDetect:	;�������߂����o���ꂽ�ꍇ�̃W�����v��
		mov	sp,cx		;SP���A
	;--- INT 06H�x�N�^���A
		push	dx
		mov	ax,es
		mov	ds,ax
		mov	dx,bx
		mov	ax,2506H
		int	21H
		pop	dx
		sti
	;--- ���W�X�^���A
		pop	es
		pop	ds
	;DX=1 : 80186,V33A
	;DX=2 : 80286
	;DX=3 : 386
	;DX=4 : 486