.386
.model flat, stdcall

include \masm32\include\masm32rt.inc

printMessage macro message, title 
  invoke MessageBox, 0, offset message, offset title, 0
endm

divide macro value, divider
  mov eax, value
  mov ebx, divider
  cdq
  idiv ebx
endm

.data?
  denominator dd 1 dup(?)
  buff        db 64 dup(?)
  result      dd 5 dup(?)

.data 
  data_title  db "5-22-IM-13-Sytnyk", 0
  data        db "Formula: (-25/a + c - b*a)/(1 + c*b/2)", 10,
                 "a = %i", 10,
                 "b = %i", 10,
                 "c = %i", 10,
                 "(-25/%i + %i - %i*%i)/(1 + %i*%i/2) = %i", 10,              
                 "Final result = %i", 10, 0
  data_error  db "Formula: (-25/a + c - b*a)/(1 + c*b/2)", 10,
                 "a = %i", 10,
                 "b = %i", 10,
                 "c = %i", 10,
                 "(-25/%i + %i - %i*%i)/(1 + %i*%i/2) = undefined", 10,  
                 "Cannot divide by 0", 10, 0
                
  a_values    dd  5, -5,  5, 25, 25,  5
  b_values    dd -2, -7, 12, -3, 12,  2
  c_values    dd  4,  4, -3, -2,  2, -1
  
.code
main:
  mov esi, 0
  
  .while esi < 6
    ;; Calculating denominator
    mov eax, b_values[esi * 4]
    mov ecx, c_values[esi * 4]
    imul eax, ecx ;; (c*b)
    divide eax, 2 ;; (c*b/2)
    add eax, 1 ;; (1 + c*b/2)

    mov denominator, eax

    ;; If denominator = 0 show error message
    .if denominator == 0
      invoke wsprintf, addr buff, addr data_error,
        a_values[esi * 4], b_values[esi * 4], c_values[esi * 4], 
        a_values[esi * 4], c_values[esi * 4], b_values[esi * 4], a_values[esi * 4], c_values[esi * 4], b_values[esi * 4]
      printMessage buff, data_title
    .else 
      ;; Continue calculating
      divide -25, a_values[esi * 4] ;; (-25/a)

      mov ecx, c_values[esi * 4] 
      add eax, ecx ;; (-25/a + c)

      mov ebx, b_values[esi * 4]
      mov ecx, a_values[esi * 4]
      imul ebx, ecx ;; (b*a)

      sub eax, ebx ;; (-25/a + c - b*c)
      divide eax, denominator ;; (-25/a + c - b*a) / (1 + c*b/2)
      
      mov result, eax

      ;; Checking for result to be even or odd
      test eax, 1
      jnz odd_num
      jz even_num

      ;; Processing different types of answers
      odd_num:
        imul eax, 5 ;; multiply result by 5
        jmp show_data
      even_num:
        mov ecx, 2
        cdq
        idiv ecx ;; divide result by 2
        jmp show_data
      show_data: 
        invoke wsprintf, addr buff, addr data,
          a_values[esi * 4], b_values[esi * 4], c_values[esi * 4], 
          a_values[esi * 4], c_values[esi * 4], b_values[esi * 4], a_values[esi * 4], c_values[esi * 4], b_values[esi * 4],
          result, eax
        printMessage buff, data_title
    .endif
    inc esi
  .endw
  invoke ExitProcess, 0
end main
