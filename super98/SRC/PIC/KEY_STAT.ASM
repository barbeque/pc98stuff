; �L�[�N���b�N�������v���O����

code	segment
	assume	cs:code,ds:code

	org	100h

p_start:
	jmp	p_entry

pro_id	db	'KEY_CLICK2',0	; �풓�`�F�b�N�pID

	even
iv_adr	label	dword		; INT-09H
iv_ofs	dw	0		; �I�t�Z�b�g�ۑ��p
iv_seg	dw	0		; �Z�O�����g�ۑ��p

entmask	db	0		; �ē��֎~�t���O
key_n	db	0		; �L�[�R�[�h���̃��[�N

; INT-09H�G���g��

iv_ent proc far
	pushf
	call	dword ptr cs:iv_adr	; �{���̊��荞�ݏ���
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
	sti
	push	ax
	mov	al,06h
	out	37h,al
	mov	ax,10000
cloop:
	jmp	$+2
	dec	ax
	jnz	cloop
	mov	al,07h
	out	37h,al
	pop	ax
	mov	cs:entmask,0
iv_end:
	iret
iv_ent endp

p_entry proc
	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	ax,3509h
	int	21h		; INT-09H �x�N�^�ǂݏo��
	mov	iv_ofs,bx
	mov	iv_seg,es

	mov	di,offset pro_id
	mov	si,di
	mov	cx,10
	cld
	repe cmpsb		; �풓�`�F�b�N
	jz	remove		; �풓����

	mov	dx,offset iv_ent
	mov	ax,2509h
	int	21h		; �x�N�^��������

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
	push	ds
	mov	es,iv_seg	; �풓�v���O�����̃Z�O�����g
	lds	dx,es:iv_adr	; �풓�v���O��������INT-09H���x�N�^
	mov	ax,2509h
	int	21h		; �x�N�^�������߂�
	pop	ds

	mov	es,iv_seg	; �풓�v���O�����̃Z�O�����g
	mov	ax,4900h
	int	21h		; �풓���̃R�[�h�G���A�����

	mov	ax,4c00h
	int	21h		; �I��
p_entry endp

code	ends
	end	p_start