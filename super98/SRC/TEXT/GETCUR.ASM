	.MODEL	small,c
	.CODE

; void GetGdcCursor(int *colum, int *line)
; ----------------------------------------
; �e�L�X�g�p��GDC���猻�݂̃J�[�\���ʒu���擾����B
; �J�[�\��OFF�̏�Ԃł͐������ʒu���擾�ł��Ȃ��ꍇ������B

GetGdcCursor PROC colum:PTR WORD, line:PTR WORD
gdcloop:
	pushf
	cli			; ���̃v���O�����Ƃ̋�������̂��ߊ����݋֎~
	in	al,60h		; �f�c�b�̃X�e�[�^�X�𒲂ׂ�
	test	al,04h		; �e�h�e�n����
	jz	gdcwait		; ��łȂ����gdcwait��
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	jmp	$+2
	mov	al,0e0h		; �f�c�b��CSRR�R�}���h
	out	62h,al		; �f�c�b�ɃR�}���h�o��
gdcbusy:
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	jmp	$+2
	in	al,60h		; �f�c�b�̃X�e�[�^�X�𒲂ׂ�
	test	al,01h		; �R�}���h���s�I����
	jz	gdcbusy		; �I���łȂ����gdcbusy��
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	jmp	$+2
	in	al,62h		; �A�h���X�f�[�^�ǂݍ���
	mov	bl,al		; �A�h���X�̉��ʃo�C�g��ۑ�
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	jmp	$+2
	in	al,62h		; �A�h���X�f�[�^�ǂݍ���
	mov	bh,al		; �A�h���X�̏�ʃo�C�g��ۑ�
	mov	cx,3		; �㑱�̂R�f�[�^��ǂݔ�΂�
gdcskip:
	jmp	$+2		; ���J�o���[�^�C���p
	jmp	$+2
	jmp	$+2
	in	al,62h		; �f�[�^��ǂݔ�΂�
	loop	gdcskip
	popf
	mov	ax,bx		; �ǂݏo�����A�h���X
	sub	dx,dx
	mov	bx,80		; ��ʂ̂P�s�̕�����
	div	bx		; ax�ɍs���Cdx�Ɍ����i�[
	mov	bx,line		; �s�̊i�[�A�h���X
	mov	[bx],ax		; �J�[�\���ʒu�i�s�j���i�[
	mov	bx,colum	; ���̊i�[�A�h���X
	mov	[bx],dx		; �J�[�\���ʒu�i���j���i�[
	ret

gdcwait:
	popf
	jmp	$+2		; �f�c�b�̂e�h�e�n����ɂȂ�܂ł̑҂�����
	jmp	$+2
	jmp	SHORT gdcloop

GetGdcCursor ENDP

	END