function [xq, bit] = cuantUniforme(x, xmax, n)
  
% DESCRIPCI�N: cuantiza x sobre (-xmax, xmax) usando 2^n niveles.
% ENTRADAS:    - x = se�al de entrada.
%              - xmax = magnitud m�xima de la se�al a ser cuantizada.
%              - n = n�mero de bits de cuantizaci�n.
% SALIDAS:     - xq = se�al cuantizada.

%vector que contendr� la se�al en binario para luego graficar los 6 tipos de se�al
bit = [];

#con esto no se permite que haya espacios entre los bits
last = -1; 

#validar que la entrada sea correcta 
if (nargin~=3) 
	disp('N�mero incorrecto de argumentos de entrada');
	return;
end

#cantidad de franjas de amplitud a cuantizar 
L = 2 ^ n;    

#distancia dentre intervalos de amplitud 
Delta = (2 * xmax) / L; 

#se seleccionan los valores enteros de los valores de amplitud que vamos a utilizar      
%q={...,-2,-1,0,1,2,...,L-1,L,L+1,...}
q = floor(L * ((x + xmax) / (2 * xmax)));  

%quitamos los valores repetidos  
unique(q);

#truncamos los que son mayores o iguales a L  
i = find(q > L - 1); 

% q={...,-2,-1,0,1,2,...,L-1}
q(i) = L - 1;   

%quitamos los valores repetidos                        
unique(q);

#truncamos los que son menores a 0                           
% q={0,1,2,...,L-1}
i = find(q < 0); 
q(i) = 0;   

%quitamos los valores repetidos     
unique(q);

#truncamiento a los puntos medios de los valores 
xq = (q * Delta) - xmax + (0.5 * Delta); 

%quitamos los valores repetidos  
unique(xq);

%iteramos sobre el vector q para obtener las se�ales cuantizadas
for i = 1 : length(q)
  if (last != q(i))
    str = dec2bin(q(i));
    
    #si a la cadena de bits le faltan 0 se les asignan a la izquierda 
    if (length(str) < n) 
      ceros = num2str(zeros(1, (n - length(str))));
      ceros = ceros(~isspace(ceros));
      
      %str tiene almacenada la codificaci�n
      str = strcat(ceros, str);
    endif
    
    #concatenar todas las se�ales cuantizadas obtenidas
    for j = 1 : length(str) 
      bit = [bit str2num(str(j))];
    end
    
    %actualizamos last
    last = q(i); 
  endif
end

#devolvemos el arreglo llmadao bit con las se�ales concatenadas y xq con las se�ales cuantizadas