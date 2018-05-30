		TITLE DISK I/O

		.8086
		.MODEL	SMALL,C

		.CODE


;==========
;unsigned char DriveToDaua(unsigned char drive);
;MS-DOS�̃h���C�u����DA/UA�i�f�o�C�X��ʁ^���j�b�g�ԍ��j�ɕϊ�����
;----------
;����
;  drive : �h���C�u���i'A'..'Z'�j
;�߂�l
;	0      = BIOS�A�N�Z�X�s�\�ȃh���C�u
;	70�`73 = 640KB FD, ���pFD I/F��640KB I/F���[�h
;	80�`83 = SASI HD�i82H�`83H��H98�̂݁j
;	90�`93 = 1MB FD, ���pFD I/F��1MB I/F���[�h
;	A0�`A7 = SCSI HD
;����
;  JOIN,SUBST�̐ݒ�ɂ�����炸�A�N�����̃h���C�u���蓖�Ăɏ]��
;----------
DriveToDaua	PROC	NEAR,drive:BYTE
;0060H:006CH �� A:�`P:��DA/UA���X�g������B

	.DATA?
DriveDauaMap	DB	10H DUP(?)
		DB	0AH DUP(?)
DriveDauaMap2	DB	26D DUP(?,?)
		DB	01H DUP(?,?)
		DB	10H DUP(?)

	.CODE
		mov	bh,0
		mov	bl,drive
		sub	bl,'A'		;'A'��0��
	;--- MS-DOS ���i�ԍ��`�F�b�N
		mov	cl,12H
		mov	ax,0000H
		int	0DCH
		cmp	ax,0000H
		je	old_type	;�V�������g���Ȃ�
	;--- �V�����ϊ�
		cmp	bl,'Z'-'A'	;A:�`Z:�h���C�u���L��
		ja	error
		mov	cl,13H
		mov	dx,OFFSET DriveDauaMap
		int	0DCH
		shl	bx,1
		inc	bx
		mov	al,DriveDauaMap2[bx]
		jmp	check
	;--- �������ϊ�
old_type:	cmp	bl,'P'-'A'	;A:�`P:�h���C�u���L��
		ja	error
		mov	ax,0060H	;MS-DOS�̃��[�N�G���A
		mov	es,ax
		mov	al,es:[006CH+bx]
	;--- �͈̓`�F�b�N
check:		cmp	al,70H		;00H�`6FH��error
		jb	error
		cmp	al,0A8H		;A8H�`FFH��error
		jae	error
		cmp	al,0A0H		;A0H�`A7H��SCSI check
		jae	ScsiCheck
		test	al,0CH		;x4H�`xFH��error
		jnz	error
good:		mov	ah,00H
		ret
error:		mov	ax,00H
		ret
	;--- SCSI�`�F�b�N
	;	3.5"MO��SCSI HD��DA/UA���������A����DA/UA�ł�
	;	DISK BIOS�ŃA�N�Z�X�ł��Ȃ��̂ŁA��������o����B
ScsiCheck:	push	ax
		mov	ah,84H		;�Z���X
		int	1BH		;DISK BIOS
		pop	ax
		jc	error
		jmp	good
DriveToDaua	ENDP


END

