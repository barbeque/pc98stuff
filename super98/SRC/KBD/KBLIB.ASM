		TITLE Keyboard Type Check

		.8086
		.MODEL	SMALL,C

		.CODE


;==========
;int GetKeyType(void);
;�L�[�{�[�h�̎�ނ��擾����
;----------
;����
;  �Ȃ�
;�߂�l
;  bit 6: vf�1�`5��f�6�`10�ϊ��i1=�K�v�C0=�s�v�j
;  bit 5: NFER�i1=����C0=�Ȃ��j
;  bit 4: HOME�i1=����C0=�Ȃ��j
;  bit 3: vf�1�`5�C�ޯ�����āi1=����C0=�Ȃ��j
;  bit 2: BS,DEL,HELP,ROLL UP,ROLL DOWN�i1=����C0=�Ȃ��j
;  bit 1: CAPS,�J�i�\�t�g�E�F�A����@�\�i1=����C0=�Ȃ��j
;  bit 0: NUM�\�t�g�E�F�A����@�\�i1=����C0=�Ȃ��j
;----------
		PUBLIC	GetKeyType
GetKeyType	PROC
;--- �V�L�[�{�[�h����
	;---�ȉ��Ɏ����悤�ɁAAH�ɃL�[�{�[�h��������
	;bit 6 = 0000:0481 bit 6�i�L�[�{�[�h����(1)�j
	;bit 3 = 0000:0481 bit 3�i�L�[�{�[�h����(2)�j
		push	es
		mov	ax,0000H	;�V�X�e�����ʈ�
		mov	es,ax
		mov	ah,es:[0481H]	;�L�[�{�[�h����(1),(2)��AL bit 6,3
		and	ah,48H
	;--- �^�C�v����
		cmp	ah,40H		;�q�`�^�C�v����
		mov	al,0101110B	;    /NFER/    /vf/HELP/LOCK/   
		je	Quit
		cmp	ah,48H		;�k�r�^�C�v����(vf�ϊ��s�v)
		mov	al,0101111B	;    /NFER/    /vf/HELP/LOCK/NUM
		je	Quit
		cmp	ah,08H		;�k�r�^�C�v����(vf�ϊ��K�v)
		mov	al,1100111B	;�ϊ�/NFER/    /  /HELP/LOCK/NUM
		je	Quit
;--- ���L�[�{�[�h����
	;--- �ȉ��Ɏ����悤�ɁAAH�ɋ@���������
	;bit 7 = 0000:0500 bit 0�i�@����(1)�j
	;bit 6 = 0000:0501 bit 4�i�@����(3)�j
	;bit 5 = 0000:0501 bit 3�i�@����(4)�j
		mov	ah,es:[0500H]	;�@����(1)��bit7
		and	ah,01H
		ror	ah,1
		mov	al,es:[0501H]	;�@����(3),�@����(4)��bit 6,5
		and	al,18H
		shl	al,1
		shl	al,1
		or	ah,al
	;--- �^�C�v����
		cmp	ah,00H		;����^�C�v����
		mov	al,0000100B	;    /    /    /  /HELP/    /   
		je	Quit
		test	ah,20H		;�w�`�^�C�v����
		mov	al,0111100B	;    /NFER/HOME/vf/HELP/    /   
		jnz	Quit
		test	ah,80H		;�u�l�^�C�v����
		mov	al,0100100B	;    /NFER/    /  /HELP/    /   
		jnz	Quit
;--- �k�s�^�g�`����
		push	bx
		mov	ax,0B600H	;�J�[�h�T�C�Y�擾�R�}���h
		int	1FH		;�������J�[�hBIOS
		pop	bx
		cmp	ax,0B600H	;LT�Ȃ�AX�̒l�͕s�ρCHA�Ȃ�K���ω�
		mov	al,0100000B	;    /NFER/    /  /    /    /   (LT)
		je	Quit
		mov	al,0100100B	;    /NFER/    /  /HELP/    /   (HA)
Quit:		mov	ah,00H
		pop	es
		ret
GetKeyType	ENDP


;==========
;int KeyTouch(int KeyCodeGroup);
;�A����������Ă���L�[�̉�������
;----------
;����
;  KeyCodeGroup : BIOS AH=04 INT 18H�̃L�[�R�[�h�O���[�v�ԍ�
;�߂�l
;  �L�[�R�[�h�O���[�v���̃L�[�̉������
;�@�\
;  �I�[�g���s�[�g����L�[�������Â���ƁA�I�[�g���s�[�g�̂��߂�
;  �\�t�g�E�F�A����̓L�[����������Ă��Ȃ��悤�Ɍ����Ă��܂��u�Ԃ�
;  ����B���̊֐��ł̓L�[���s�[�g���Ă��Ă��������Ă��邩�ǂ�����
;  ���ׂ邱�Ƃ��ł���B
;����
;  ���̊֐��̎��s�ɂ͐�ms������B
;----------
		PUBLIC	KeyTouch
KeyTouch	PROC	NEAR,KeyCodeGroup:WORD
	;--- �L�[������Ԏ擾�i�P��ځj
		mov	ax,KeyCodeGroup
		mov	ah,04H
		int	18H
		mov	bl,ah
	;--- 1ms�ȏ�̃E�F�C�g
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
		mov	cx,300H
waitloop:	out	dx,al
		loop	waitloop
	;--- �L�[������Ԏ擾�i�Q��ځj
		mov	ax,KeyCodeGroup
		mov	ah,04H
		int	18H
	;--- �P��ڂƂQ��ڂ̉�����Ԃ��n�q����
		or	ah,bl
		mov	al,ah
		mov	ah,00H
		ret
KeyTouch	ENDP


;==========
;int GetKeyBeepMode(void);
;----------
;����
;  �Ȃ�
;�߂�l
;  0 = �r�[�v��炷�i�f�t�H���g�j
;  1 = �r�[�v��炳�Ȃ�
;�@�\
;  �L�[�o�b�t�@���I�[�o�[�t���[�����Ƃ��Ƀr�[�v��炷���[�h��
;  �ǂ������擾����֐�
;----------
		PUBLIC	GetKeyBeepMode
GetKeyBeepMode	PROC
		mov	ax,0000H	;ES���V�X�e�����ʈ�
		mov	es,ax
		mov	al,es:[0500H]	;bit 5
		and	ax,0020H
		shl	al,1
		shl	al,1
		rol	al,1
		ret
GetKeyBeepMode	ENDP


;==========
;void KeyBeepOn(void);
;----------
;����
;  �Ȃ�
;�߂�l
;  �Ȃ�
;�@�\
;  �L�[�o�b�t�@���I�[�o�[�t���[�����Ƃ��Ƀr�[�v��炷
;  ���[�h�ɐݒ肷��֐�
;----------
		PUBLIC	KeyBeepOn
KeyBeepOn	PROC
		mov	ax,0000H	;ES���V�X�e�����ʈ�
		mov	es,ax
		and	es:[0500H],BYTE PTR 0DFH	;bit 5=0
		ret
KeyBeepOn	ENDP


;==========
;void KeyBeepOff(void);
;----------
;����
;  �Ȃ�
;�߂�l
;  �Ȃ�
;�@�\
;  �L�[�o�b�t�@���I�[�o�[�t���[�����Ƃ��Ƀr�[�v��炳�Ȃ�
;  ���[�h�ɐݒ肷��֐�
;----------
		PUBLIC	KeyBeepOff
KeyBeepOff	PROC
		mov	ax,0000H	;ES���V�X�e�����ʈ�
		mov	es,ax
		or	es:[0500H],BYTE PTR 20H		;bit 5=1
		ret
KeyBeepOff	ENDP


;==========
;void CapsSwitch(int sw);
;CAPS�L�[��ON/OFF����
;----------
;����
;  sw = 0 : OFF
;  sw = 1 : ON
;�߂�l
;  �Ȃ�
;�@�\
;����
;----------
		PUBLIC	CapsSwitch
CapsSwitch	PROC	NEAR,sw:WORD
	;�L�[�{�[�h�����̃}�X�N
		cli
		in	al,0002H
		or	al,02H
		out	0002H,al
		sti
	;LED����R�}���h���o
		mov	ah,9DH		;LED����R�}���h
		call	KbSendCommand
		jc	quit		;�G���[�Ȃ璆�~
	;LED ON/OFF��񑗏o
		push	es
		mov	ax,0000H	;ES���V�X�e�����ʈ�
		mov	es,ax
		mov	ah,es:[053AH]
		pop	es
		shl	ah,1
		and	ah,08H		;�Ő���r�b�g���c���}�X�N
		or	ah,70H
		cmp	sw,0000H
		je	off
		or	ah,04H		;CAPS ON
off:		call	KbSendCommand
quit:	;KB BIOS�C�j�V�����C�Y
		mov	ah,03H
		int	18H
	;�L�[�{�[�h��������
		cli
		in	al,0002H
		and	al,NOT 02H
		out	0002H,al
		sti
		ret
CapsSwitch	ENDP


;==========
;void KanaSwitch(int sw);
;�J�i�L�[��ON/OFF����
;----------
;����
;  sw = 0 : OFF
;  sw = 1 : ON
;�߂�l
;  �Ȃ�
;�@�\
;����
;----------
		PUBLIC	KanaSwitch
KanaSwitch	PROC	NEAR,sw:WORD
	;�L�[�{�[�h�����̃}�X�N
		cli
		in	al,0002H
		or	al,02H
		out	0002H,al
		sti
	;LED����R�}���h���o
		mov	ah,9DH
		call	KbSendCommand
		jc	quit		;�G���[�Ȃ璆�~
	;LED ON/OFF��񑗏o
		push	es
		mov	ax,0000H	;ES���V�X�e�����ʈ�
		mov	es,ax
		mov	ah,es:[053AH]
		pop	es
		shl	ah,1
		and	ah,04H		;CAPS����r�b�g���c���}�X�N
		or	ah,70H
		cmp	sw,0000H
		je	off
		or	ah,08H		;�� ON
off:		call	KbSendCommand
quit:	;KB BIOS�C�j�V�����C�Y
		mov	ah,03H
		int	18H
	;�L�[�{�[�h��������
		cli
		in	al,0002H
		and	al,NOT 02H
		out	0002H,al
		sti
		ret
KanaSwitch	ENDP


;==========
;int GetKbType(void);
;�L�[�{�[�h�̃^�C�v���擾����
;----------
;����
;  �Ȃ�
;�߂�l
;  0 = ���^
;  1 = �V�^
;�@�\
;����
;----------
		PUBLIC	GetKbType
GetKbType	PROC	NEAR
	;�L�[�{�[�h�����̃}�X�N
		cli
		in	al,0002H
		or	al,02H
		out	0002H,al
		sti
	;�L�[�{�[�h�^�C�v�擾�R�}���h���s
		mov	ah,9FH
		call	KbSendCommand
		jc	oldtype
		call	KbReceiveData	;�f�[�^��M
		jc	oldtype
		cmp	al,0A0H		;0A0H ?
		jne	oldtype
		call	KbReceiveData	;�f�[�^��M
		jc	oldtype
		cmp	al,80H		;80H ?
		jne	oldtype
		mov	bx,0001H
		jmp	SHORT quit
oldtype:	mov	bx,0000H
quit:	;�L�[�{�[�h�����̋���
		cli
		in	al,0002H
		and	al,NOT 02H
		out	0002H,al
		sti
		mov	ax,bx
		ret
GetKbType	ENDP


;----------
;�L�[�{�[�h�ւ̃f�[�^���M
;�����FAH���L�[�{�[�h�ɑ��M����R�}���h
;�ߒl�FCF=0 : ����I��
;      CF=1 : �G���[�I��
;----------
		PUBLIC	KbSendCommand
KbSendCommand	PROC	NEAR
	;--- 8251A�ɃR�}���h���[�h�����i���M���j
SendRetry:	mov	al,00010111B	;KB�p8251A�̐ݒ�
			;  ^^^^^^^^
			;  |||||||+-KB I/F���M�ݒ�i1=���j
			;  ||||||+--DTR#�ݒ�i1=LOW�jKB���g���C��v��
			;  |||||+---KB I/F��M�ݒ�i1=���j
			;  ||||+----�u���[�N���M�ݒ�i0=���Ȃ��jKBؾ�Ă��Ȃ�
			;  |||+-----�G���[�t���O�̃N���A�i1=����j
			;  ||+------RTS#�ݒ�i0=HIGH�jKB����̑��M������
			;  |+-------���Z�b�g�i0=���Ȃ��j
			;  +--------Don't care
		out	0043H,al
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
		mov	cx,0007H	;4��s�ȏ�̃E�F�C�g(I/Oض���)
	@@:	out	dx,al
		loop	@b
	;--- �L�[�{�[�h�ɃR�}���h�f�[�^���M
		mov	al,ah
		out	0041H,al
		mov	cx,0007H	;4��s�ȏ�̃E�F�C�g(I/Oض���)
	@@:	out	dx,al
		loop	@b
	;--- 8251A�ɃR�}���h���[�h�����i���M�֎~�j
		mov	al,00010110B	;KB�p8251A�̃��[�h�ݒ�
			;  ^^^^^^^^
			;  |||||||+-KB I/F���M�ݒ�i0=�֎~�j
			;  ||||||+--DTR#�ݒ�i1=LOW�jKB���g���C��v��
			;  |||||+---KB I/F��M����
			;  ||||+----�u���[�N���M�ݒ�i0=���Ȃ��jKBؾ�Ă��Ȃ�
			;  |||+-----�G���[�t���O�̃N���A�i1=����j
			;  ||+------RTS#�ݒ�i0=HIGH�jKB����̑��M������
			;  |+-------���Z�b�g�i0=���Ȃ��j
			;  +--------Don't care
		out	0043H,al
	;--- �A�N�m���b�W�m�F
		mov	bl,00H
AckRetry:	call	KbReceiveData
		jc	TimeOut
		cmp	al,0FAH		;ACK ?
		jne	NotAck
		clc			;����I��
		ret
NotAck:		cmp	al,0FCH		;NACK ?
		je	SendRetry
		inc	bl
		cmp	bl,04H
		jne	AckRetry	;��ACK,��NACK��4���M������G���[�I��
TimeOut:	stc
		ret
KbSendCommand	ENDP


;----------
;�L�[�{�[�h����̃f�[�^��M
;�����F�Ȃ�
;�ߒl�FCF=0 : AL���L�[�{�[�h����̒l
;      CF=1 : �^�C���A�E�g
;----------
		PUBLIC	KbReceiveData
KbReceiveData	PROC	NEAR
		mov	cx,8000H	;�^�C���A�E�g�ɂȂ�RDY#�`�F�b�N��
RdyCheckLoop:	in	al,0043H	;RDY#�`�F�b�N
		test	al,02H
		jnz	Ready
		loop	RdyCheckLoop
		stc			;�^�C���A�E�g
		ret
Ready:		;�E�F�C�g�pOUT�|�[�g�̃A�h���X����
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
		mov	cx,18H		;37��sec�ȏ�E�F�C�g
ReceiveLoop:	out	dx,al
		loop	ReceiveLoop
	;�X�e�[�^�X�ǂݏo��
		in	al,0043H
		and	al,38H
	;�G���[�������RTY#=ACTIVE�A�Ȃ����RTY#=INACTIVE
		jnz	ReceiveError
		mov	al,00010110B	;RTY#=1(INACTIVE)
		out	0043H,al
		mov	cx,0007H	;4��s�ȏ�̃E�F�C�g(I/Oض���)
	@@:	out	dx,al
		loop	@b
		in	al,0041H	;��M�f�[�^�ǂݏo��
		clc			;�L�����[���N���A
		ret
ReceiveError:	mov	al,00010100B	;RTY#=0(ACTIVE)
		out	0043H,al
		mov	cx,0007H	;4��s�ȏ�̃E�F�C�g(I/Oض���)
	@@:	out	dx,al
		loop	@b
		in	al,0041H	;��M�f�[�^�ǂݏo��
		stc			;�L�����[���Z�b�g
		ret
KbReceiveData	ENDP


END