	.MODEL	small,c
	.CODE

ToSjis	PROC chcode:WORD
	mov	ax,chcode	; �i�h�r�����R�[�h���擾
	cmp	ah,21h		; �i�h�r�����R�[�h�̂P�o�C�g�ڂ͈̔̓`�F�b�N
	jb	error
	cmp	ah,7eh		; �͈̓`�F�b�N
	ja	error
	cmp	al,21h		; �i�h�r�����R�[�h�̂Q�o�C�g�ڂ͈̔̓`�F�b�N
	jb	error
	cmp	al,7eh		; �͈̓`�F�b�N
	ja	error
	sub	ah,21h		; 21h�`7dh��00h�`5ch�ɕϊ�
	shr	ah,1		; 00h�`5ch��00h�`2eh�ɕϊ�
	jnc	conv1		; �ϊ��O��ah�������Ȃ�conv1��
	add	al,5eh		; 21h�`7eh��7fh�`dch�ɕϊ�
conv1:
	add	al,1fh		; 21h�`dch��40h�`fbh�ɕϊ�
	cmp	al,7eh		; +1�␳���K�v��
	jbe	conv2		; +1�␳���s�v�Ȃ�conv2��
	inc	al		; 7fh�`fbh��80h�`fch�ɕϊ�
conv2:
	add	ah,81h		; 00h�`2eh��81h�`afh�ɕϊ�
	cmp	ah,9fh		; 81h�`9fh��
	jbe	pend		; 81h�`9fh�Ȃ�ϊ��I����
	add	ah,40h		; a0h�`afh��e0h�`efh�ɕϊ�
	jmp	SHORT pend	; �ϊ��I����
error:
	sub	ax,ax		; 0�̓G���[���̃��^�[���l
pend:
	ret
ToSjis	ENDP

	END
