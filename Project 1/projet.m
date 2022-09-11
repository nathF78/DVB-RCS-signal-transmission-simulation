%Projet TS MARTIN GUIDEZ NATHAN FOUCHER 1-SN-C

clc;
clear all;
close all;
load donnees1.mat;
load donnees2.mat;

Ns = 10;
Te = 1/(120e3);
Fe = 1/Te;
Ts = Ns*Te;
ordre = 61; %ordre des filtres, on choisit 61 pour avoir une petite fenetre de transistion
fp1 = 0;
fp2 = 46e3;

tiledlayout(4,4);

%création des signaux modulants 
m1 = [bits_utilisateur1*2-1];
m2 = [bits_utilisateur2*2-1];
m1 = repelem(m1,Ns);
m2 = repelem(m2,Ns);

t = [0:Te:(480*Ts-Te)];
temp = [0:Te:(2400*Ts-Te)];
F = [0:1/Ts:(480/Te-1/Ts)];

nexttile;
plot(t,m1);
ylabel("m1");
xlabel("t (s)");
title("tracé de m1")

nexttile;
plot(t,m2);
ylabel("m2");
xlabel("t (s)");
title("tracé de m2")

nexttile;
pwelch(m1,[],[],[],1/Te,'twosided');
title("Quetch m1 ");

nexttile;
pwelch(m2,[],[],[],1/Te,'twosided');
title("Quetch m2 ");

%On place les slots
s1=[zeros(1,4800),m1,zeros(1,4800*3)];
s2=[zeros(1,4800*4),m2];

nexttile;
plot(temp,s1);
xlabel("t(s)")
title("m1 dans son slot")

nexttile;
plot(temp,s2);
xlabel("t(s)")
title("m2 dans son slot")

%création des ondes porteuses 
p1 = cos(2*pi*[0:Te:5*0.040-Te]*fp1);
p2 = cos(2*pi*[0:Te:5*0.040-Te]*fp2);

%modulation
x1 = s1.*p1;
x2 = s2.*p2;

%construciton de x(t)
SNRdB = 100;
x = x1 + x2;
Pbruit = mean(abs(x).^2)/(10^(SNRdB/10));
x = x + Pbruit*randn(1,length(x1));

nexttile;
plot(temp,x);
ylabel("x");
xlabel("t (s)");
title("x transmis");
X=fftshift(fft(x));

nexttile;
pwelch(x,[],[],[],1/Te,'twosided');
title("Quetch x transmis ");

%filtre passe bas m1
fc=23e3;
tfiltre=[-Te/2*(ordre-1):Te:Te/2*(ordre-1)];
Ffiltre=[-Fe/2*(ordre-1):Fe:Fe/2*(ordre-1)];
hpb=2*fc/Fe*sinc(tfiltre*2*fc);

%Application du passe bas
x1f=conv(x,hpb,'same');

nexttile;
plot(tfiltre,abs(hpb));
xlabel("temps en s");
title("Reponse impulsionnelle de hpb ");

PB=fftshift(fft(hpb));

nexttile;
plot(Ffiltre,abs(PB));
xlabel("frequence en Hz");
title("Reponse frequencielle de hpb ");

%DST du passe bas et spectre 
nexttile;
x1fpwelch = pwelch(x1f,[],[],length(x1f),1/Te,'centered');
semilogy(linspace(-Fe/2,Fe/2,length(x1fpwelch)),x1fpwelch);
hold on;
semilogy(linspace(-Fe/2,Fe/2,length(PB)),(abs(PB)));
title("DST de x(t) (bleu) apres pb/spectre pb (orange)");
xlabel("f(Hz)");
hold off;

%filtre passe haut hph
hph = -hpb;
hph(round(length(hph)/2)) = hph(round(length(hph)/2)) + 1;

nexttile;
plot(Ffiltre,hph);
xlabel("temps en s");
title("Reponse impultionnelle de hph ");

PH=fftshift(fft(hph));

nexttile;
plot(Ffiltre,abs(PH));
xlabel("frequence en Hz");
title("Reponse frequencielle de hph ");

%Application du passe haut
x2f = conv(x,hph,'same');

%DST du passe-haut et spectre
nexttile;
x2fpwelch = pwelch(x2f,[],[],length(x2f),1/Te,'centered');
semilogy(linspace(-Fe/2,Fe/2,length(x2fpwelch)),x2fpwelch);
hold on;
semilogy(linspace(-Fe/2,Fe/2,length(PH)),(abs(PH)));
title("DST de x(t) (bleu) apres pb/spectre ph (orange)");
xlabel("f(Hz)");
hold off;

%Affichage des signaux résultants
nexttile;
plot(temp,x1f);
title("x(t) apres pb");
xlabel("t(s)");

nexttile;
plot(temp,x2f);
title("x(t) apres ph");
xlabel("t(s)");


%Retour en bande de base
x1f = x1f.*p1;
x2f = x2f.*p2;

%Demodulation d'amplitude
x1f=conv(x1f,hpb,'same');
x2f=conv(x2f,hpb,'same');

%detection du slot utile 
slots1= divideslot(x1f);
slots2= divideslot(x2f);

%On retrouve les deux messages
SignalFiltre1=filter(ones(1,Ns),1,slots1) ;
SignalEchantillonne1=SignalFiltre1(Ns :Ns :end) ;
BitsRecuperes1=(sign(SignalEchantillonne1)+1)/2 ;
txt = bin2str(BitsRecuperes1)

SignalFiltre1=filter(ones(1,Ns),1,slots2) ;
SignalEchantillonne1=SignalFiltre1(Ns :Ns :end) ;
BitsRecuperes1=(sign(SignalEchantillonne1)+1)/2 ;
txt = bin2str(BitsRecuperes1)

%Fonction pour detecter les slots utiles 
function slot = divideslot(x)
    slot1 = x(1:4800);
    slot2 = x(4801:4800*2);
    slot3 = x(4800*2+1:4800*3);
    slot4 = x(4800*3+1:4800*4);
    slot5 = x(4800*4+1:end);
    v = [slot1; slot2; slot3; slot4; slot5];
    [~, idx] = max([mean(slot1.^2), mean(slot2.^2), mean(slot3.^2), mean(slot4.^2), mean(slot5.^2)]);
    slot=v(idx,:);

end
