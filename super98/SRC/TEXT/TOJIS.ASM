	.MODEL	small,c
	.CODE

ToJis	PROC chcode:WORD
	mov	ax,chcode	; VtgihrΏR[hπζΎ
	cmp	ah,81h		; PoCgΪΜΝΝ`FbN
	jb	error
	cmp	ah,9fh		; ΝΝ`FbN
	jbe	conv1		; ΝΝΰΘηΟ·Φ
	cmp	ah,0e0h		; ΝΝ`FbN
	jb	error
	cmp	ah,0efh		; ΝΝ`FbN
	ja	error
conv1:
	and	ah,3fh		; 81h`9fhΖe0h`efhπ01h`2fhΙΟ·
	add	ah,ah		; 01h`2fhπ02h`5ehΜτΙΟ·
	add	ah,1fh		; 02h`5ehπ21h`7dhΜοΙΟ·
	cmp	al,40h		; QoCgΪΜΝΝ`FbN
	jb	error
	cmp	al,7fh		; ΝΝ`FbN
	jb	conv2		; ΝΝΰΘηΟ·Φ
	jz	error
	cmp	al,0fch		; ΝΝ`FbN
	ja	error
	cmp	al,09fh		; ihrΏΜτR[h©`FbN
	jae	conv3		; τζΘηΟ·Φ
	sub	al,20h		; 80h`9ehπ60h`7ehΙΟ·
	jmp	SHORT pend
conv2:
	sub	al,1fh		; 40h`7ehπ21h`5fhΙΟ·
	jmp	SHORT pend
conv3:
	inc	ah		; PoCgΪπο¨τΙΟ·
	sub	al,7eh		; 9fh`fchΜR[hπ21h`7ehΙΟ·
	jmp	SHORT pend
error:
	sub	ax,ax		; 0ΝG[Μ^[l
pend:
	ret
ToJis	ENDP

	END
