; �L�[�N���b�N�������v���O����

code	segment
	assume	cs:code,ds:code

	org	100h

p_start:
	jmp	p_entry

pro_id	db	'KEY_CLICK3',0	; �풓�`�F�b�N�pID

	even
iv_adr	dd	8 dup (0)

entmask	db	0


iv_08h	proc far
	int	08h		; �{���̊��荞�ݏ������N��
	iret
iv_08h	endp

iv_09h	proc far
	int	09h		; �{���̃L�[�{�[�h���荞�ݏ������N��

	push	ax
	in	al,43h		; �X�e�[�^�X
	test	al,02h		; ��M�f�[�^�����邩
	pop	ax
	jnz	iv_end		; ��M�f�[�^������Ύ�M�f�[�^�͓ǂ܂Ȃ�
	push	ax
	in	al,41h		; �L�[�{�[�h����̎�M�f�[�^��ǂ�
	test	al,80h		; 0:Make, 1:Break
	pop	ax
	jnz	iv_end

	cmp	cs:entmask,0	; �ē��`�F�b�N
	jnz	iv_end
	mov	cs:entmask,1
	sti			; ���荞�݂�����
	push	ax
	mov	al,06h		; �r�[�vON
	out	37h,al
	mov	ax,1000
cloop:
	out	5fh,al		; �E�F�C�g�|�[�g
	dec	ax
	jnz	cloop
	mov	al,07h		; �r�[�vOFF
	out	37h,al
	pop	ax
	mov	cs:entmask,0
iv_end:
	iret
iv_09h	endp

iv_0ah	proc far
	int	0ah		; �{���̊��荞�ݏ������N��
	iret
iv_0ah	endp

iv_0bh	proc far
	int	0bh		; �{���̊��荞�ݏ������N��
	iret
iv_0bh	endp

iv_0ch	proc far
	int	0ch		; �{���̊��荞�ݏ������N��
	iret
iv_0ch	endp

iv_0dh	proc far
	int	0dh		; �{���̊��荞�ݏ������N��
	iret
iv_0dh	endp

iv_0eh	proc far
	int	0eh		; �{���̊��荞�ݏ������N��
	iret
iv_0eh	endp

iv_0fh	proc far
	int	0fh		; �{���̊��荞�ݏ������N��
	iret
iv_0fh	endp


p_entry proc
	mov	ax,cs
	mov	ds,ax
	mov	ax,3588h
	int	21h		; �풓�v���O�����̃x�N�^�ǂݏo��
	mov	di,offset pro_id
	mov	si,di
	mov	cx,10
	cld
	repe cmpsb		; �풓�`�F�b�N
	jz	remove		; �풓����

	cli
	mov	di,offset iv_adr
	mov	al,88h		; INT-88H�`INT-8FH���g�p
	mov	cx,8
vr_loop:
	mov	ah,35h
	int	21h		; �x�N�^�ǂݏo��
	mov	[di],bx
	add	di,2
	mov	[di],es
	add	di,2
	inc	al
	loop	vr_loop

	mov	si,offset iv_tbl
	mov	al,88h		; INT-88H�`INT-8FH���g�p
	mov	cx,8
vw_loop:
	mov	dx,[si]
	add	si,2
	mov	ah,25h
	int	21h		; �x�N�^��������
	inc	al
	loop	vw_loop

	mov	al,11h
	out	00h,al		; ICW1����������
	mov	al,88h		; �g�p�x�N�^�ԍ�88H�`8FH
	out	02h,al		; ICW2����������
	mov	al,80h
	out	02h,al		; ICW3����������
	mov	al,1dh
	out	02h,al		; ICW4����������
	sti

	mov	es,word ptr cs:[002ch]	; ���G���A�̃Z�O�����g�擾
	mov	ax,4900h
	int	21h		; ���G���A�����

	mov	dx,offset p_entry
	mov	cl,4
	shr	dx,cl
	inc	dx		; �풓�T�C�Y�v�Z
	mov	ax,3100h
	int	21h		; �풓�I��

iv_tbl	dw	iv_08h
	dw	iv_09h
	dw	iv_0ah
	dw	iv_0bh
	dw	iv_0ch
	dw	iv_0dh
	dw	iv_0eh
	dw	iv_0fh

; �풓�����̏���

remove:
	cli
	mov	al,11h
	out	00h,al		; ICW1����������
	mov	al,08h		; �g�p�x�N�^�ԍ�08H�`0FH
	out	02h,al		; ICW2����������
	mov	al,80h
	out	02h,al		; ICW3����������
	mov	al,1dh
	out	02h,al		; ICW4����������

	mov	ax,3588h
	int	21h		; �풓�v���O�����̃x�N�^�ǂݏo��
	mov	si,offset iv_adr
	mov	al,88h		; INT-88H�`INT-8FH���g�p
	mov	cx,8
rm_loop:
	mov	dx,es:[si]
	add	si,2
	push	ds
	mov	ds,es:[si]
	add	si,2
	mov	ah,25h
	int	21h		; �x�N�^��������
	pop	ds
	inc	al
	loop	rm_loop
	sti

	mov	ax,4900h
	int	21h		; �풓���̃R�[�h�G���A�����
	mov	ax,4c00h
	int	21h		; �I��
p_entry endp

code	ends
	end	p_start