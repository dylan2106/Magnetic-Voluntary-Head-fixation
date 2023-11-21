Fs = 44100;
L = 1;
fInd = 1;
%%
%make a smoothing window
smL = 0.010;
Nwin = numel(0:(1/Fs):(smL*2));
winEdge = hanning(Nwin);

win = ones(numel(0:(1/Fs):L),1);k
win(1:Nwin./2) = winEdge(1:Nwin./2);
win = flipud(win);
win(1:Nwin./2) = winEdge(1:Nwin./2);


fInd = 1;
f0 = 50; 
f1 = 5000;
y=chirp(0:(1/Fs):L,f0,L,f1,'logarithmic')';% .* win;
wavwrite(y,Fs,16,sprintf('%d_chirp_log_%dhz_%dhz_%ds.wav',fInd,f0,f1,L))

fInd = 2;
f0 = 5000; 
f1 = 50;
y=chirp(0:(1/Fs):L,f0,L,f1,'logarithmic')';% .* win;
wavwrite(y,Fs,16,sprintf('%d_chirp_log_%dhz_%dhz_%ds.wav',fInd,f0,f1,L))

fInd = 3;
t = 0 : 1/Fs: L;
d = [0 : 1/1e3 : 10e-3 ; 0.8.^(0:10)]';
y = pulstran(t,d,'gauspuls',10e3,0.5);
wavwrite(y,Fs,16,sprintf('%d_pulstran_1hz.wav',fInd))

%%
Fs = 44100;
L = 0.03;
fInd = 1;

tones = round(logspace(2,4,11));
tones(2) = 150; 
tones(1) = [];
tones = [150 252 441 630 1050 1575 2450 4410 6300 11025];

T = 1/Fs;                     % Sample time
n = Fs*L;                     % Length of signal
t = (0:n-1)*T;                % Time vector
for i = 1:numel(tones)
    x = sin(2*pi*tones(i)*t);
    plot(t,x+(i*2));hold on
    
    %truncate the sample such that it ends to better wrap
    
%     ind = n-floor(Fs./tones(i)):n;
%     plot(t(ind),x(ind)+(i*2),'r');
%     
%     [~, maxind] = max(x(ind(x(ind)<0)));
%     lastVal = ind(maxind);
%     
%     plot(t(lastVal),x(lastVal)+(i*2),'*g');
    %wavwrite([x],Fs,16,sprintf('%d_sine_tone_%dhz_%dms.wav',29+i,tones(i),L*1000))
     audiowrite(sprintf('%d_sine_tone_%dhz_%dms.wav',29+i,tones(i),L*1000), [x],Fs)


end

%% generate some white noise
Fs = 44100;
L = [0.01 0.03  0.1 0.3 1 3];
for i  = 1:numel(L)
  x = wgn(Fs*L(i),1,0)/3;
  audiowrite(sprintf('%d_white_noise_%dms.wav',11+i,L(i)*1000), [x],Fs)

end

%% generate the NIC sound aka FM wiggle
Fs = 44100;


fmList = [5, 2.5]
for i = 1:numel(fmList)
    L = 1/fmList(i);
    T = 1/Fs;                     % Sample time
    n = Fs*L;                     % Length of signal
    t = (0:n-1)*T;                % Time vector
    
    f = 1000;
    fm = fmList(i);
    famp = 200;

    x2 = sin(2*pi*fm*t);
    
    x = fmmod(x2,f,Fs,200);
    
    hold off
    plot(t,x+(i*2));hold on
    %soundsc(x,Fs)
    
    filename = sprintf('%d_FM_wiggle_f%.1fhz_fm%.1fhz_famp%.1fhz_%dms.wav',39+i,f,fm,famp,L*1000);
    filename= regexprep(filename,'\.(0)','');
    filename= regexprep(filename,'\.(?!wav())','p');

    audiowrite( filename, [x],Fs)
end

%%
%%
Fs = 44100;
L = 0.1;
fInd = 1;

tones = round(logspace(2,4,11));
tones(2) = 150; 
tones(1) = [];
tones = [1500 2000];

T = 1/Fs;                     % Sample time
n = Fs*L;                     % Length of signal
t = (0:n-1)*T;                % Time vector
for i = 1:numel(tones)
    x = sin(2*pi*tones(i)*t);
    plot(t,x+(i*2));hold on
     audiowrite(sprintf('%d_sine_tone_%dhz_%dms.wav',43+i,tones(i),L*1000), [x],Fs)
end


