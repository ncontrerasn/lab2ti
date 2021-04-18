%{
construyendo m(t)
hacemos un for para saber cu�ntas sinusoides vana a componer m(t)
se itera para saber cu�l es la frecuencia maxima
%}

%inicializar m(t) en 0 para luego ir sumando las sinusoides
mt = 0;

%cantidad de sinusoides
n = input('Cantidad de sinusoides: ');

#frecuencia m�xima inicializada en -1
fm = -1;    

#arreglo de amplitudes de las sinusoides                       
ai = [1 : n];   

#arreglo de frecuencias de las sinusoides                                
fi = [1 : n];  

#arreglo de selcciones, 1 para seno y 2 para coseno                           
selection = [1 : n];   

%for para tomar las frecuencias, amplitudes y ver el tipo de se�al (seno o coseno) de todas las sinusoides y actulizar la frecuencia m�xima              
for i = 1 : n
  printf("Sinusoide #%d\n", i);
  ai(1, i) = input('Amplitud : ');
  fi(1, i) = input('Frecuencia: ');
  
  #aqu� se decide si las sinusoides son senos o cosenos concretamnete 
  selection(1, i) = input('[1 -> seno, 2 -> coseno]: ');
 
  #se actualiza la frecuencia m�xima. Aqu� hacemos que se cumpla el teorema del muestreo  
  if (fm < fi(1, i))
    fm = fi(1, i);                       
  endif
end

#frecuencia de muetreo
fs = 20 * fm;        

#intervalo de muestreo                       
Ts = 1 / fs;     

%duraci�n de la se�al                           
T = 1;     

%arreglo del tiempo                            
t = [0 : Ts : T];    

%cadena para hacer despu�s la demodulaci�n                        
cadena = '0';

%for para sumar a m(t) todas las sinusoides y actulizar la cadena para demodular
for i = 1 : n
  
  %caso seno
  if (selection(1, i) == 1)
    mt = mt + ai(1, i) * sin(2 * pi * fi(1, i) * t);
    cadena = strcat(cadena, ' + ', int2str(ai(1, i)), '*sin(2*pi*', int2str(fi(1, i)), '*t)');
  
  %caso coseno
  elseif (selection(1,i) == 2)
    mt = mt + ai(1, i) * cos(2 * pi * fi(1, i) * t);
    cadena = strcat(cadena, ' + ', int2str(ai(1, i)), '*cos(2*pi*', int2str(fi(1, i)), '*t)');
  endif
end  

%obtener la transformada de Fourier de m(t)
X = fftshift(fft(mt) * Ts);                         
N = length(X);

#se hace el ajuste correspondiente para poder representar de forma lo m�s parecida posible, la transformada te�rica con la transformada original. 
df = (1 / (N * Ts));                      
tN = [ -(ceil((N - 1) / 2) : -1 : 1), 0, (1 : floor((N - 1) / 2)) ] * df;

#arreglo de la funci�n cuantificada
[xsq, bits] = cuantUniforme(mt, 1, 4);            

%gr�fica #1: contiene la se�al muestreada, se�al cuantizada, la transformada de fourier y las 6 reprentaciones 
figure(1);

#graficamos la se�al muestreada
subplot(3, 3, 1);
stem(t, mt, 'b');
title('Se�al muestreada');
xlabel('t');
ylabel('mt(t) (muestreada)');
axis([0 T -sum(ai(:)) sum(ai(:))]);

#graficamos la se�al cuantizada
subplot(3, 3, 2);
stem(t, xsq, 'r');
title('Se�al cuantizada');
xlabel('t'); 
ylabel('mt(t) [Cuantizada]');
axis([0 T -1.1 1.1]);

#graficamos la transformada de Fourier de la se�al muestreada
subplot(3, 3, 3);
stem(tN, abs(X), 'k');
title('FFT de la se�al muestreada');
xlabel('w'); 
ylabel('X(w)');

#cantidad de bits concatenados obtenidos en la funci�n cuantUniforme
Xmax = length(bits);

#datos que determinan la presici�n de la gr�fica, especifica el n�mero de puntos en el eje horizontal
datos = 1000;

# vector de unos 
unos = ones(1, datos);

%vector de ceros
ceros = zeros(1, datos);

# vector para graficar cada tipo de codificaci�n
array = [];

#unipolar NRZ
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  ceros];      
    case 1
      array = [array  unos];
  end
end

%gr�fica
t_2 = (0 : (length(array) - 1)) / datos;
subplot(3, 3, 4);
plot(t_2, array);
title('Unipolar NRZ');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#bipolar NRZ
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  -unos]; # En este caso los 0 son represntados como -1
    case 1
      array = [array  unos];
  end
end

%gr�fica
subplot(3, 3, 5);
plot(t_2, array);
title('Bipolar NRZ');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#unipolar RZ
RZ = [ones(1, datos/2) zeros(1, datos / 2)]; # Se concatena un 0 a la mitad de cada pulso
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  0 * RZ];
    case 1
      array = [array  RZ];
  end
end

%gr�fica
subplot(3, 3, 6);
plot(t_2, array);
title('Unipolar RZ');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#bipolar RZ
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  -RZ];
    case 1
      array = [array  RZ];
  end
end

%gr�fica
subplot(3, 3, 7);
plot(t_2,array);
title('Bipolar RZ');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#AMI
count = 0;
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  0*RZ];
    case 1
      if rem(count, 2) == 0
        array = [array  RZ];
      else
        array = [array  -RZ];
      endif
      count++;
  end
end

%gr�fica
subplot(3, 3, 8);
plot(t_2, array);
title('AMI');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#manchester
MAN = [ones(1, datos / 2)  -ones(1, datos / 2)];
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  -MAN];
    case 1
      array = [array  MAN];
  end
end

%gr�fica
subplot(3, 3, 9);
plot(t_2, array);
title('Manchester');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

#funci�n m
m = inline(cadena, 't');

#Devolvemos la se�al recuperada con los valores de la muestra
%mrec es la sumatoria de la se�al para demodular
mrec = 0;

%ecuaci�n 5.2 con sinc
for i = 0 : 1 : T / Ts
  
  %mr guarda los coeficientes de la se�al m(t) al iterar sobre ella
  mr = (m(i * Ts));
  
  %sumando todos los elementos de mr
  mrm = sum(mr( : ));
  
  %sumatoria, se hace uso de la funci�n sinc para simplificar c�lculos
  mrec = mrec + (mrm * (sinc(2 * fs * (t - i * Ts))));
endfor

%gr�fica #2: contiene la se�al muestreada y la se�al recuperada por demodulaci�n
figure(2);

%gr�fica de la se�al muestreada
subplot(2, 1, 1);
stem(t, mt, 'b');
title('Se�al muestreada');
xlabel('t');
ylabel('x(t)');
axis([0 1 -sum(ai( : )) sum(ai( : ))]);

%gr�fica de la se�al recuperada
subplot(2, 1 ,2);
plot(t, mrec, 'b');
title('Se�al recuperada');
xlabel('t');
ylabel('x(t)');
axis([0 1 -sum(ai( : )) sum(ai( : ))]);