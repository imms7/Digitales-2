.text 

_main: 
    addi a0,x0,12     #Primer parámetro x = 12 
    addi a1,x0,3      #Segundo parámetro y = 3 
    jal ra, _funcion 
    
fin: 
    jal x0, fin 
    
_funcion: 
     add a0,a0,a1    #z = x+y 
     jalr x0, ra, 0  #return z
     