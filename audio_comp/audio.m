[y,fs]=audioread('nothing.mp3');
% [cA,cD] = dwt(y,'db8');
 dt = 1/fs;
t = 0:dt:(length(y)*dt)-dt;
% plot(t,y);
% x=(length(y)/2)+7;
% t1 = 0:dt:(x*dt)-dt;
% figure 
% plot(t1,cA);
% figure 
% plot(t1,cD);
X = dct(y);
[XX,ind] = sort(abs(X),'descend');
plot(t,XX);
figure
plot(t,ind);
figure 
plot(t,X);
figure
z=idct(X);
plot(t,z);

