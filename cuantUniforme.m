function [xq,bit]=cuantUniforme(x,xmax,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPCIÓN: cuantiza x sobre (-xmax,xmax) usando 2^n niveles.
% ENTRADAS: - x=señal de entrada.
%                     - xmax=magnitud máxima de la señal a ser cuantizada.
%                     - n=número de bits de cuantización.
% SALIDAS: - xq=señal cuantizada.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bit = [];
last = -1;  #Con esto se permite que no haya espacios entre los bits
if (nargin~=3) # Se valida que la entrada sea correcta 
	disp('Número incorrecto de argumentos de entrada');
	return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L=2^n;    #Cantidad de franjas de amplitud a cuantizar 
Delta=(2*xmax)/L; #distancia dentre intervalos de amplitud 
q=floor(L*((x+xmax)/(2*xmax)));    #Se seleccionan los valores enteros de los valores de amplitud que vamos a utilizar      % q={...,-2,-1,0,1,2,...,L-1,L,L+1,...}
unique(q);
i=find(q>L-1); q(i)=L-1;   #Truncamos los que son mayores o iguales a L                        % q={...,-2,-1,0,1,2,...,L-1}
unique(q);
i=find(q<0); q(i)=0;       #Truncamos los que son menores a 0                           % q={0,1,2,...,L-1}
unique(q);
xq = (q*Delta)-xmax+(0.5*Delta); #Aquí se hace el truncamiento a los puntos medios de nuestros valores 
unique(xq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(q)
  if (last != q(i))
    str = dec2bin(q(i));
    if (length(str) < n) #Si a la cadena de bits le faltan 0 se les asignan a la izquierda 
      ceros = num2str(zeros(1,(n-length(str))));
      ceros = ceros(~isspace(ceros));
      str = strcat(ceros,str);
    endif
    %str #imprimimos para debugging la cadena
    for j = 1:length(str) #vamos a concatenar todas las señales cuantizadas obtenidas
      bit = [bit str2num(str(j))];
    end
    last = q(i); 
  endif
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 #Devolvemos "bit" con las señales concatenadas y xq con las señales cuantizadas. 