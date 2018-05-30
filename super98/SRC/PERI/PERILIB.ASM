		TITLE MemorySwitch

		.8086
		.MODEL	SMALL,C

		.CODE

;==========
;unsigned char GetMemorySwitch(unsigned char number);
;�w�肵���������X�C�b�`�̒l��ǂ�
;----------
;����
;  number : �������X�C�b�`�̔ԍ��i�P�`�W�j
;�߂�l
;  �������X�C�b�`�̓��e
;�@�\
;  �m�[�}���C�n�C���]�C�k�s�^�g�`�̔��ʂ����A�w�肳�ꂽ�������X�C�b�`����
;  �l��ǂݏo���B
;----------
GetMemorySwitch	PROC	NEAR,number:BYTE
		mov	ax,0000H	;ES��0000�i�V�X�e�����ʈ�j
		mov	es,ax
		mov	ax,es:[0500H]
		and	ax,1001H	;LT,HA����
		cmp	ax,1000H
		je	BiosUse
		test	es:[0501H],BYTE PTR 08H	;�n�C���]����
		jnz	BiosUse
		;** �m�[�}�����[�h�̏��� **
		mov	ax,0A000H	;�e�L�X�g�u�q�`�l�Z�O�����g
		mov	es,ax		;ES���������X�C�b�`�̃Z�O�����g
		mov	bh,00H		;3FE2H��(number-1)AND 7���S�{�����l��
		mov	bl,number	;���Z����ƖړI�̃������X�C�b�`��
		dec	bl		;�A�h���X�ɂȂ�
		and	bl,07H
		add	bx,bx
		add	bx,bx
		mov	al,es:[3FE2H+bx]	;�������X�C�b�`�Ǐo
		mov	ah,0
		ret
		;** �n�C���]�CLT/HA�̏����iBIOS�g�p�j **
BiosUse:	mov	ah,21H		;�������X�C�b�`�Ǐo
		mov	al,number
		int	18H
		mov	al,dl
		mov	ah,0
		ret
GetMemorySwitch	ENDP


;==========
;void SetMemorySwitch(unsigned char number, unsigned char value);
;�w�肵���������X�C�b�`�ɒl������
;----------
;����
;  number : �������X�C�b�`�̔ԍ��i�P�`�W�j
;  value  : �ݒ肷��l
;�߂�l
;  �Ȃ�
;�@�\
;  �m�[�}���C�n�C���]�C�k�s�^�g�`�̔��ʂ����A�n�C���]�C�k�s�^�g�`�Ȃ�
;  �a�h�n�r���g�p����B�m�[�}���Ȃ烁�����X�C�b�`���������݉ɂ���
;  �w�肳�ꂽ�������X�C�b�`�ɒl���Z�b�g���A�������X�C�b�`����������
;  �s�ɂ���B
;----------
SetMemorySwitch	PROC	NEAR,number:BYTE, value:BYTE
		mov	ax,0000H	;ES��0000�i�V�X�e�����ʈ�j
		mov	es,ax
		mov	ax,es:[0500H]
		and	ax,1001H	;LT,HA����
		cmp	ax,1000H
		je	BiosUse
		test	es:[0501H],BYTE PTR 08H	;�n�C���]����
		jnz	BiosUse
		;** �m�[�}�����[�h�̏��� **
		mov	ax,0A000H	;�e�L�X�g�u�q�`�l�̃Z�O�����g
		mov	es,ax		;ES���������X�C�b�`�̃Z�O�����g
		mov	bh,00H		;3FE2H��(number-1)AND 7���S�{�����l��
		mov	bl,number	;���Z����ƖړI�̃������X�C�b�`��
		dec	bl		;�A�h���X�ɂȂ�
		and	bl,7
		add	bx,bx
		add	bx,bx
		;�������X�C�b�`����������
		mov	al,0DH
		out	68H,al
		;�������X�C�b�`�ɏ�������
		mov	al,value	;�������X�C�b�`�֏�������
		mov	es:[bx+3FE2H],al
		;�������X�C�b�`�������֎~
		mov	al,0CH
		out	68H,al
		ret
		;** �n�C���]�CLT/HA�̏����iBIOS�g�p�j **
BiosUse:	mov	ah,22H		;�������X�C�b�`����
		mov	al,number
		mov	dl,value
		int	18H
		ret
SetMemorySwitch	ENDP


;==========
;int ExistExtRom(int CheckSegment);
;�g���������̈�̃��������ݒ���
;----------
;����
;  �Ȃ�
;�߂�l
;   0 = �������Ȃ�
;   1 = ����������
;�@�\
;  CheckSegment�Ŏw�肳�ꂽ�Z�O�����g�̐擪4KB�Ƀ�������
;  ���݂��邩�ǂ����𒲂ׂ�B
;----------
AREA_SIZE EQU 1000H	;4KB		;�P�̂q�n�l�̈�̃T�C�Y
INTERVAL  EQU 10H	;16bytes	;�����Ԋu�i�������̂��ߑS�Ă͒��ׂȂ��j

ExistExtRom	PROC	USES ds si, CheckSegment:WORD
		mov	ds,CheckSegment
	;--- FFH�Ǐo�̃e�X�g
		;�S��FFH �� �����^�Ǐo�e�X�g�i�q�`�l�`�F�b�N�j
		;���̑��̒l���ǂ߂� �� �A�N�e�B�u�^�[�~�l�[�^�̂��߂̃e�X�g
		mov	cx,AREA_SIZE / 4
		mov	si,0000H	;�����J�n�Ԓn�̃I�t�Z�b�g
		cld
RomTestLoop:	push	cx		;rep lodsw��p���āA�f�[�^�o�X��
		mov	cx,0002H	;  �d�������肵�Ă���̒l���r����
		cli
		rep	lodsw		;  �i�n�C���]�Ή��̂��߁B�m�[�}����
		sti			;�@�����Ȃ�ǂ�ł����v�j
		pop	cx
		cmp	ax,0FFFFH	;�ǂݏo�����l��FFFFH�łȂ�������
		jne	AtTest		;���̑��̒l���ǂ߂� �� AT�̂��߂̊m�F��
		loop	RomTestLoop
		;			;�S��FFH �� RAM���ǂ����̊m�F��


	;--- �����^�Ǐo�e�X�g�i�q�`�l�`�F�b�N�j
		;�������񂾒l���ǂ݂������i�q�`�l����j������������
		;�������񂾒l���ǂ݂����Ȃ����������Ȃ�
		mov	cx,AREA_SIZE / INTERVAL
		mov	si,0000H	;SI��0000H
		mov	ax,si		;AX��0000H
		mov	bx,ax
		dec	bx		;BX��FFFFH
RamTestLoop:	cli			;�����֎~
		push	[si]		;[SI]�̒l��ۑ�
		mov	[si],ax		;[SI]��0000H����������
		cmp	[si],ax		;[SI]�̒l��0000H�Ɣ�r
		jne	RamTest1
		mov	[si],bx		;[SI]��FFFFH����������
		cmp	[si],bx		;[SI]�̒l��FFFFH�Ɣ�r
RamTest1:	pop	[si]		;[SI]�̒l�𕜋A
		sti			;��������
		je	MemoryPresent	;��v������u�q�`�l����v
		add	si,INTERVAL
		loop	RamTestLoop
		jmp	MemoryAbsent	;�u�q�`�l�Ȃ��v


	;--- �A�N�e�B�u�^�[�~�l�[�^�i�`�s�j�̂��߂̃e�X�g
AtTest:		mov	cx,AREA_SIZE / INTERVAL
		mov	si,0000H
AtTestLoop:	cli			;�����֎~
		mov	ax,[si]		;[SI]��AX�ɓǂݍ���
		cmp	ax,[si]		;�Ă�[SI]��ǂ�AX�Ɣ�r
		sti			;��������
		je	MemoryPresent	;��v�����烁��������
		add	si,INTERVAL
		loop	AtTestLoop
;		jmp	MemoryAbsent	;��v���Ȃ������烁�����Ȃ�


MemoryAbsent:	mov	ax,0000H	;�������Ȃ�
		ret
MemoryPresent:	mov	ax,0001H	;����������
		ret
ExistExtRom	ENDP


;==========
;unsigned int GetPrnStat(void);
;�v�����^�̏�Ԏ擾
;----------
;����
;  �Ȃ�
;�߂�l
;   0 : �f�[�^���M�\���
;   1 : �a�t�r�x��ԁi�n�C���]�C�g�X�W�̂݃T�|�[�g�j
;   2 : �^�C���A�E�g�ő��M�s�\�������i�n�C���]�C�g�X�W�̂݃T�|�[�g�j
;   3 : �f�B�Z���N�g���
;   4 : �y�[�p�[�G���h�i�n�C���]�C�g�X�W�̂݃T�|�[�g�j
;   5 : �v�����^���ڑ��܂��͓d���n�e�e
;�@�\
;  �v�����^�̏�Ԃ𒲂ׂ�B�n�C���]�C�g�X�W�ł̓t���Z���g���j�N�X�h�^�e����
;  �v�����^�̏ڍׂȏ�Ԃ��擾����B�m�[�}���i���g�X�W�j�ł͏ڍׂȏ��𓾂�
;  ���Ƃ��s�\�Ȃ̂ŁABUSY�[�q�̐U���������Ԃ𐄒肷��B�������A���̏ꍇ
;  �v�����^�̎d�l�ɂ���Ắu�f�B�Z���N�g��ԁv�����o�ł��Ȃ��@�������B
;----------
GetPrnStat	PROC	NEAR
	;�n�C���]�Ȃ�A�v�����^�a�h�n�r��12H�����s���ă��^�[��
		mov	ax,0000H	;ES��0000�i�V�X�e�����ʈ�j
		mov	es,ax
		test	es:[0501H],BYTE PTR 08H	;�n�C���]�^�m�[�}������
		jz	Normal
		mov	ah,12H		;�X�e�[�^�X�擾
		int	1AH
		mov	al,ah
		mov	ah,00
		ret
Normal:
	;�t���Z���g���T�|�[�g�Ȃ�A�v�����^�a�h�n�r��18H�����s���ă��^�[��
		test	es:[0458H],BYTE PTR 02H	;�t���Z���g���\�r�b�g����
		jz	MiniCentro
		mov	ah,18H		;�Z���X
		int	1AH
		mov	al,ah
		mov	ah,00
		ret
;--- �ȉ��A�ȈՃZ���g���j�N�X���[�h�̂Ƃ��̏��� ---
MiniCentro:
	;�v�����^���a�t�r�x�Ȃ�A�d���n�m�łn�e�e�k�h�m�d
		in	al,0042H	;BUSY�M���`�F�b�N(zero active)
		test	al,04H
		jz	offline		;�A�N�e�B�u�Ȃ�I�t���C��
	;�E�F�C�g�pOUT�|�[�g�̃A�h���X����
		;����E�F�M��BFDBH�i�}�E�X���������ݒ�p�|�[�g�j
		;���̑�    ��005FH�i�E�F�C�g�p�|�[�g�j
		push	es
		mov	dx,0000H	;ES���V�X�e�����ʈ�
		mov	es,dx
		mov	dx,0BFDBH
		test	es:[0500H],WORD PTR 1801H	;����E�F�M���o
		jz	@f
		mov	dx,005FH
	@@:	pop	es
	;DC1�𑗂�iDC1�ȊO�̃R�[�h�ł��v�����^���]�v�ȓ�������Ȃ���Ηǂ��j
		mov	al,11H		;�v�����^�|�[�g��11H(DC1)���Z�b�g
		out	0040H,al
		out	dx,al		;0.6��s�E�F�C�g
		out	dx,al		;������x
		mov	al,0EH		;PSTB#�A�N�e�B�u
		out	0046H,al
		out	dx,al		;0.6��s�E�F�C�g
		out	dx,al		;������x
		or	al,01H		;PSTB#�C���A�N�e�B�u
		out	0046H,al
	;�a�t�r�x����u�A�N�e�B�u�ɂȂ�����v�����^�d���n�m�Ɣ��f
	;��莞�ԑ҂��Ă��A�N�e�B�u�ɂȂ�Ȃ���Γd���n�e�e�Ɣ��f
		mov	cx,1000H
BusyCheckLoop:	in	al,0042H	;BUSY�M���`�F�b�N(zero active)
		test	al,04H
		jz	online		;�A�N�e�B�u�ɂȂ�΃I�����C��
		loop	BusyCheckLoop
		mov	ax,0005H
		ret
online:		mov	ax,0000H
		ret
offline:	mov	ax,0003H
		ret
GetPrnStat	ENDP


;==========
;void PrinterSelect(void);
;�v�����^�������I�ɃZ���N�g��Ԃɂ���
;�ifor PC-PR(except Page Printer)�CNM series�j
;----------
;�@�\
;  �v�����^�������I�ɃZ���N�g�ɂ���B�������A�v�����^�̎d�l�ɂ���Ă�
;  �v�����^�|�[�g�o�R�ŋ����I�ɃZ���N�g�ł��Ȃ��@��iPC-PR�̃y�[�W�v
;  �����^�CESC/P�v�����^�Ȃǁj������B
;  �Z���N�g�������������ǂ�����GetPrnStat�Œ��ׂ�B
;----------
PrinterSelect	PROC	NEAR
		push	es
		mov	ax,0000H	;ES��0000�i�V�X�e�����ʈ�j
		mov	es,ax
		mov	ah,04H
		test	es:[0501H],BYTE PTR 08H	;�n�C���]�^�m�[�}������
		jz	FullCentro
		test	es:[0458H],BYTE PTR 04H	;H98 NORMAL�̃t���Z���g��
		jnz	FullCentro
		mov	ah,0EH
FullCentro:
		;�E�F�C�g�pOUT�|�[�g�̃A�h���X����
		;����E�F�M��BFDBH�i�}�E�X���������ݒ�p�|�[�g�j
		;���̑�    ��005FH�i�E�F�C�g�p�|�[�g�j
		mov	dx,0BFDBH
		test	es:[0500H],WORD PTR 1801H	;����E�F�M���o
		jz	@f
		mov	dx,005FH
	@@:	pop	es
		mov	al,11H		;�v�����^�|�[�g��11H(DC1)���Z�b�g
		out	0040H,al
		out	dx,al		;0.6��s�E�F�C�g
		out	dx,al		;������x
		mov	al,ah		;PSTB#���A�N�e�B�u
		out	0046H,al
		out	dx,al		;0.6��s�E�F�C�g
		out	dx,al		;������x
		or	al,01H		;PSTB#���C���A�N�e�B�u
		out	0046H,al
		ret
PrinterSelect	ENDP



;==========
;int ExistSoundBoard(void);
;�T�E���h�@�\�̑��ݒ���
;----------
;����
;  �Ȃ�
;�߂�l
;   0 = �T�E���h�@�\�Ȃ�
;   1 = �T�E���h�@�\����B�q�n�l�Ȃ��i�n�C���]�܂ށj
;   2 = �T�E���h�@�\����B�T�E���h�q�n�l����
;�@�\
;  �T�E���h�@�\�̗L���Ƃ��̂q�n�l�̗L���𒲂ׂ�B
;----------
ExistSoundBoard	PROC	NEAR
	;--- OPN�̗L������
		mov	cx,0100H	;256��J��Ԃ�
OpnCheckLoop:	mov	dx,0188H	;�n�o�m�X�e�[�^�X�|�[�g
		in	al,dx
		cmp	al,0FFH
		jne	OpnExist	;FF�łȂ����OPN����
		loop	OpnCheckLoop
		mov	ax,0000H
		jmp	Quit
OpnExist:
	;--- �n�C���]����
		mov	ax,0000H	;ES��0000�i�V�X�e�����ʈ�j
		mov	es,ax
		test	es:[0501H],BYTE PTR 08H	;�n�C���]�^�m�[�}������
		mov	ax,0001H
		jnz	Quit		;�n�C���]�Ȃ�q�n�l�Ȃ�
	;--- �q�n�l���ݔ���
		mov	ax,0CC00H
		mov	es,ax
		mov	ax,0001H	;�q�n�l�Ȃ��̖߂�l
		mov	bx,2E00H	;INT�x�N�^�G���g�����
		cmp	es:[bx],WORD PTR 0001H	;�G���g����
		jne	Quit
		add	bx,2
		cmp	es:[bx],WORD PTR 0000H
		jne	Quit
		add	bx,2
		cmp	es:[bx],WORD PTR 00D2H	;�x�N�^�ԍ�
		jne	Quit
		mov	ax,0002H	;�q�n�l����̖߂�l
Quit:		ret
ExistSoundBoard	ENDP


;==========
;int ExistMouseIF(void);
;�}�E�X�h�^�e�̑��ݒ���
;----------
;����
;  �Ȃ�
;�߂�l
;   0 = �h�^�e�Ȃ�
;   1 = �h�^�e����B���������ݒ�@�\�Ȃ�
;   2 = �h�^�e����B���������ݒ�@�\����
;�@�\
;  �}�E�X�h�^�e�̗L���Ƃ��̊��������ݒ�@�\�̗L���𒲂ׂ�B
;  PC-9801-71��F3/M2�����}�E�X�h�^�e�ɂ̓\�t�g�E�F�A���犄��������
;  �ݒ肷��@�\�͂Ȃ��A�{�[�h���DIP SW�Őݒ肷��B�n�C���]�̊���
;  ������120Hz�ŌŒ�B
;----------
ExistMouseIF	PROC	NEAR
		push	es
		mov	ax,0000H	;�V�X�e�����ʈ�Z�O�����g
		mov	es,ax
		mov	ax,es:[0500H]	;�@����
		test	ax,0800H	;�n�C���]����
		mov	bl,01H		;I/F����C�����ݒ�Ȃ�
		jnz	Quit
		and	ax,1001H
		cmp	ax,0000H	;����,E,F,M����
		je	BoardCheck
		cmp	ax,1000H	;PC-98LT,HA����
		mov	bl,00H		;I/F�Ȃ��C�����ݒ�Ȃ�
		je	Quit
		mov	bl,02H		;I/F����C�����ݒ肠��
		jmp	Quit		;���̑�
BoardCheck:	mov	dx,7FD9H	;�{�^��������ԁC���W�ǎ�pPORT(ɰ��)
		in	al,dx
		cmp	al,0FFH
		mov	bl,00H		;I/F�Ȃ��C�����ݒ�Ȃ�
		je	Quit
		mov	bl,01H		;I/F����C�����ݒ�Ȃ�
Quit:		mov	al,bl
		mov	ah,00H
		pop	es
		ret
ExistMouseIF	ENDP


END