; �x���������v���O����

code	segment
	assume	cs:code,ds:code

	org	100h

p_start:
	jmp	p_entry

pro_id	db	'WARNING SOUND',0	; �풓�`�F�b�N�pID

	even
iv_adr	label	dword
iv_ofs	dw	0		; �I�t�Z�b�g�ۑ��p
iv_seg	dw	0		; �Z�O�����g�ۑ��p

count	db	0		; �������ԃJ�E���^

; INT-08H�G���g��

tm_intr	proc far
	push	ax
	push	bx
	mov     al,cs:count
	inc     cs:count
	cmp     al,99
	jnz     tm_chk
	mov	cs:count,0

tm_chk:
	cmp     al,0
	jz      b_on
	cmp     al,5
	jz      b_off
	cmp     al,10
	jz      b_on
	cmp     al,15
	jz      b_off
	cmp     al,20
	jz      b_on
	cmp     al,40
	jz      b_off
	jmp	SHORT tm_end

b_on:
	mov	al,06h
	out	37h,al		; beep ON
	jmp	SHORT tm_end

b_off:
	mov	al,07h
	out	37h,al		; beep OFF
	jmp	SHORT tm_end

tm_end:
	mov	al,20h
	out	00h,al		; ���荞�݃R���g���[����EOI�𔭍s
	pop	bx
	pop	ax
	iret
tm_intr endp


p_entry proc
	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	ax,3508h
	int	21h		; INT-08H �x�N�^�ǂݏo��
	mov	iv_ofs,bx
	mov	iv_seg,es

	mov	di,offset pro_id
	mov	si,di
	mov	cx,14
	cld
	repe cmpsb		; �풓�`�F�b�N
	jz	remove		; �풓����

	pushf
	cli
	sub	ax,ax		; ���荞�݃x�N�^�e�[�u���̃Z�O�����g:0000H
	mov	es,ax
	mov	ax,offset tm_intr	; ���O�̃^�C�}���荞�ݏ���
	mov	es:[0020h],ax
	mov	es:[0022h],cs

	mov	bx,24576	; 5MHz�n�̏ꍇ�̃J�E���^�l
	mov	al,es:[0501h]	; �V�X�e�����ʈ��BIOS-FLAG
	test	al,80h		; �V�X�e���N���b�N�̃`�F�b�N
	jz	tm_set
	mov	bx,19968	; 8MHz�n�̏ꍇ�̃J�E���^�l
tm_set:
	pushf
	cli
	mov	al,36h		; �J�E���^#0�����[�h3�Ŏg�p����
	out	77h,al
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	mov	al,bl		; �J�E���^�l�̉��ʃo�C�g
	out	71h,al
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	mov	al,bh		; �J�E���^�l�̏�ʃo�C�g
	out	71h,al

	in	al,02h		; ���荞�݃R���g���[����IMR
	and	al,11111110b	; �^�C�}���荞�݂�����
	out	02h,al		; IMR����������
	popf

	mov	es,word ptr cs:[002ch]	; ���G���A�̃Z�O�����g�擾
	mov	ax,4900h
	int	21h		; ���G���A�����

	mov	dx,offset p_entry
	mov	cl,4
	shr	dx,cl
	inc	dx		; �풓�T�C�Y�v�Z
	mov	ax,3100h
	int	21h		; �풓�I��

; �풓�����̏���

remove:
	pushf
	cli
	in	al,02h		; ���荞�݃R���g���[����IMR
	or	al,00000001b	; �^�C�}���荞�݂��֎~
	out	02h,al		; IMR����������

	mov	al,07h
	out	37h,al		; beep OFF

	mov	es,iv_seg	; �풓�v���O�����̃Z�O�����g
	mov	dx,es:iv_ofs	; �풓�v���O��������INT-08H���x�N�^
	mov	cx,es:iv_seg	; �풓�v���O��������INT-08H���x�N�^
	sub	ax,ax		; �Z�O�����g:0000H
	mov	es,ax
	mov	es:[0020h],dx
	mov	es:[0022h],cx
	popf

	mov	es,iv_seg	; �풓�v���O�����̃Z�O�����g
	mov	ax,4900h
	int	21h		; �풓���̃R�[�h�G���A�����

	mov	ax,4c00h
	int	21h		; �I��
p_entry endp

code	ends
	end	p_start