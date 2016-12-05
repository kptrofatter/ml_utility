close('all');
clear();
clc();

% Grid
x = 0.0 : 0.01 : 20.0;
kind = 'Y';

% Draw
fh = figure(1);
clf(fh);
ah = axes('Parent',fh);
hold(ah,'on');
plot(x([1,end]),[0,0],'k');
gh(1) = plot(x,DBessel(0,kind,1,x),'r');
gh(2) = plot(x,DBessel(1,kind,1,x),'g');
gh(3) = plot(x,DBessel(2,kind,1,x),'b');
gh(4) = plot(x,DBessel(3,kind,1,x),'m');
gh(5) = plot(x,DBessel(4,kind,1,x),'c');
hold(ah,'off');
% Format
grid(ah,'on');
% Notate
legend(ah,gh,...
    [kind,'_0(x)'],...
    [kind,'''_0(x)'],...
    [kind,'''''_0(x)'],...
    [kind,'''''''_0(x)'],...
    [kind,'''''''''_0(x)'] ...
    );
ylim([-1,1]);
%%
m = 1;
p = [1,2,5,6];
[M,P] = ndgrid(m,p);

% Compute zeros
Z(1,:) = ZDBessel(0,kind,M,P);
Z(2,:) = ZDBessel(1,kind,M,P);
Z(3,:) = ZDBessel(2,kind,M,P);
Z(4,:) = ZDBessel(3,kind,M,P);
Z(5,:) = ZDBessel(4,kind,M,P);

hold(ah,'on');
scatter(Z(1,:),zeros(1,size(Z,2)),'r');
scatter(Z(2,:),zeros(1,size(Z,2)),'g');
scatter(Z(3,:),zeros(1,size(Z,2)),'b');
scatter(Z(4,:),zeros(1,size(Z,2)),'m');
scatter(Z(5,:),zeros(1,size(Z,2)),'c');
hold(ah,'off');


%%
nn = 4;
mm = 0;
pp = 1;

xa = pi*(pp-2+mm/2+3/4+mod(nn,2)/2);
xb = pi*(pp-1+mm/2+3/4+mod(nn,2)/2);

hold(ah,'on');
scatter([xa,xb],[0,0],'Filled');
hold(ah,'off');


