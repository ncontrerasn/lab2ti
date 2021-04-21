%{
construyendo m(t)
hacemos un for para saber cuántas sinusoides vana a componer m(t)
se itera para saber cuál es la frecuencia máxima
%}

%inicializar m(t) en 0 para luego ir sumando las sinusoides
mt = 0;

%cantidad de sinusoides
n = input('Cantidad de sinusoides: ');

#frecuencia máxima inicializada en -1
fm = -1;    

#arreglo de amplitudes de las sinusoides                       
ai = [1 : n];   

#arreglo de frecuencias de las sinusoides                                
fi = [1 : n];  

#arreglo de selcciones, 1 para seno y 2 para coseno                           
selection = [1 : n];   

%for para tomar las frecuencias, amplitudes y ver el tipo de señal (seno o coseno) de todas las sinusoides y actulizar la frecuencia máxima              
for i = 1 : n
  printf("Sinusoide #%d\n", i);
  ai(1, i) = input('Amplitud : ');
  fi(1, i) = input('Frecuencia: ');
  
  #aquí se decide si las sinusoides son senos o cosenos concretamnete 
  selection(1, i) = input('[1 -> seno, 2 -> coseno]: ');
 
  #se actualiza la frecuencia máxima. Aquí hacemos que se cumpla el teorema del muestreo  
  if (fm < fi(1, i))
    fm = fi(1, i);                       
  endif
end

#frecuencia de muetreo
fs = 20 * fm;        

#intervalo de muestreo                       
Ts = 1 / fs;     

%duración de la señal                           
T = 1;     

%arreglo del tiempo                            
t = [0 : Ts : T];    

%cadena para hacer después la demodulación                        
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

#se hace el ajuste correspondiente para poder representar de forma lo más parecida posible, la transformada teórica con la transformada original. 
df = (1 / (N * Ts));                      
tN = [ -(ceil((N - 1) / 2) : -1 : 1), 0, (1 : floor((N - 1) / 2)) ] * df;

#arreglos de la función cuantificada
%xsq tiene la señal cuantizada
%bits tiene la señal codificada para procesarse y graficar los 6 tipos de señales requeridas
[xsq, bits] = cuantUniforme(mt, 1, 4);            

%gráfica #1: contiene la señal muestreada, señal cuantizada, la transformada de fourier y las 6 reprentaciones 
figure(1);

#graficamos la señal muestreada
subplot(3, 3, 1);
stem(t, mt, 'b');
title('Señal muestreada');
xlabel('t');
ylabel('mt(t) (muestreada)');
axis([0 T -sum(ai(:)) sum(ai(:))]);

#graficamos la señal cuantizada, aquí usamos xsq
subplot(3, 3, 2);
stem(t, xsq, 'r');
title('Señal cuantizada');
xlabel('t'); 
ylabel('mt(t) [Cuantizada]');
axis([0 T -1.1 1.1]);

#graficamos la transformada de Fourier de la señal muestreada
subplot(3, 3, 3);
stem(tN, abs(X), 'k');
title('FFT de la señal muestreada');
xlabel('w'); 
ylabel('X(w)');

#cantidad de bits concatenados obtenidos en la función cuantUniforme
Xmax = length(bits);

#datos que determinan la presición de la gráfica, especifica el número de puntos en el eje horizontal
datos = 1000;

#vector de unos 
unos = ones(1, datos);

%vector de ceros
ceros = zeros(1, datos);

#vector para graficar cada tipo de codificación
array = [];

%vector de tiempo para graficar las 6 señales
t_2 = [];

#unipolar NRZ
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  ceros];      
    case 1
      array = [array  unos];
  end
end

%llenar el vector del tiempo
t_2 = (0 : (length(array) - 1)) / datos;

%gráfica
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
      #los 0 son represntados como -1
      array = [array  -unos]; 
    case 1
      array = [array  unos];
  end
end

%gráfica
subplot(3, 3, 5);
plot(t_2, array);
title('Bipolar NRZ');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#unipolar RZ
#se concatena un 0 a la mitad de cada pulso
%arreglo RZ para dar la forma de esta señal a la salida
RZ = [ones(1, datos / 2) zeros(1, datos / 2)]; 
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  0 * RZ];
    case 1
      array = [array  RZ];
  end
end

%gráfica
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

%gráfica
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

%gráfica
subplot(3, 3, 8);
plot(t_2, array);
title('AMI');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

%vaciar el arreglo de nuevo
array = [];

#manchester
%arreglo MAN para dar la forma de esta señal a la salida
MAN = [ones(1, datos / 2)  -ones(1, datos / 2)];
for i = 1 : Xmax
  switch bits(i)
    case 0
      array = [array  -MAN];
    case 1
      array = [array  MAN];
  end
end

%gráfica
subplot(3, 3, 9);
plot(t_2, array);
title('Manchester');
xlabel(['Bits']);
axis([0 Xmax -2 2]);
grid on;

#función m
m = inline(cadena, 't');

#devolvemos la señal recuperada con los valores de la muestra
%mrec es la sumatoria de la señal para demodular
mrec = 0;

%ecuación 5.2 con sinc
for i = 0 : 1 : T / Ts
  
  %mr guarda los coeficientes de la señal m(t) al iterar sobre ella
  mr = (m(i * Ts));
  
  %sumando todos los elementos de mr
  mrm = sum(mr( : ));
  
  %sumatoria, se hace uso de la función sinc para simplificar cálculos
  mrec = mrec + (mrm * (sinc(2 * fs * (t - i * Ts))));
endfor

%gráfica #2: contiene la señal muestreada y la señal recuperada por demodulación
figure(2);

%gráfica de la señal muestreada
subplot(2, 1, 1);
stem(t, mt, 'b');
title('Señal muestreada');
xlabel('t');
ylabel('x(t)');
axis([0 1 -sum(ai( : )) sum(ai( : ))]);

%gráfica de la señal recuperada usando el arreglo mrec
subplot(2, 1 ,2);
plot(t, mrec, 'b');
title('Señal recuperada');
xlabel('t');
ylabel('x(t)');
axis([0 1 -sum(ai( : )) sum(ai( : ))]);
