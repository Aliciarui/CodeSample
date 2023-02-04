%ʵ����ʽ��DFT�任�㷨
N = 16;%�źų���
xr = round(10*rand(N,1));%�������ָ������������
xrr=xr'
rdft = zeros(N,1);%��ʼ��
cb = cosbase(N);%��ȡcos����DFT������
sb = sinbase(N);%��ȡsin����

ReX = zeros(N/2+1,1);%��ʼ�����
ImX = zeros(N/2+1,1);

for i = 1 : N/2+1
    ReX(i) = cb(i,:)*xr;%DFT�任����������ԭʼ�ź����������
    ImX(i) = sb(i,:)*xr;
end

Re = zeros(N/2+1,1);%��ԭ�����ʼ��
Im = zeros(N/2+1,1);

%%����β֮��ļ��㷽ʽ
for i = 1 : N/2 +1
    Re(i) = ReX(i)/(N/2);
    Im(i) = ImX(i)/(N/2);
end

%%����0��N/2�Ǽ���������ʽ
Re(1) = ReX(1)/N;
Re(N/2+1) = ReX(N/2+1)/N;

yr=zeros(1,N);

for i = 1 : N/2+1
    yr = yr + Re(i)*cb(i,:) + Im(i)*sb(i,:);
end
yr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%������ʽ��DFT�任�㷨
M=8;%ָ���źų���
xi = round(10*rand(M,1));%�������ָ������������
xii=xi'
dftbs = dftbase(M);%������DFT��������ʽ
rdft = zeros(M,1);%��ʼ��

for k = 1 : M
    rdft(k) = sum(dftbs(k,:)*xi);
end

idft = zeros(M,1);
idftbs = idftbase(M);%������IDFT��������ʽ

for k = 1 : M
    idft(k) = sum(idftbs(k,:)*rdft)/M;%��ԭ����
end

idft

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%�ź�ȥ����
N2=1024;
t=0:1/(N2-1):1;
fs=N2-1;
n=N2;
xx=50*cos(2*pi*20*t);%�������ں���
no=30*rand(1,1024);%��������
x=xx+no;%��������
x=x';

subplot(1,2,1);
plot(x);

cb=cosbase(N2);
sb=sinbase(N2);

ReX = zeros(N2/2+1,1);
ImX = zeros(N2/2+1,1);

for i = 1 : N2/2+1
    ReX(i) = cb(i,:)*x;
    ImX(i) = sb(i,:)*x;
end

ReX(30:513)=0;%ȥ�봦��ȥ����Ƶ����
ImX(30:513)=0;
%�²���ͬʵ��DFT�任
Re = zeros(N2/2+1,1);
Im = zeros(N2/2+1,1);

for i = 1 : N2/2 + 1
    Re(i) = ReX(i)/(N2/2);
    Im(i) = ImX(i)/(N2/2);
end

Re(1) = ReX(1)/N2;
Re(N2/2+1) = ReX(N2/2+1)/N2;

y = zeros(1,N2);
for i = 1 : N2/2+1
    y = y + Re(i)*cb(i,:)+Im(i)*sb(i,:);
end
subplot(1,2,2);
plot(y);

function idftbs = idftbase(N)
cb = zeros(N,N);
for j = 1 : N
    for k = 1 :N
        idftbs(j,k) = cos(2*pi*(j-1)*(k-1)/N)+sin(2*pi*(j-1)*(k-1)/N)*i;
    end
end
end

function dftbs = dftbase(N)
cb = zeros(N,N);
for j = 1 : N
    for k = 1 : N
        dftbs(j,k) = cos(2*pi*(j-1)*(k-1)/N)-sin(2*pi*(j-1)*(k-1)/N)*i;
    end
end
end

function cb = cosbase(N)
cb = zeros(N/2+1,N);
for i = 1 : N/2+1
    for j = 1:N
        cb(i,j) = cos(2*pi*(i-1)*(j-1)/N);
    end
end
end

function sb = sinbase(N)
sb = zeros(N/2+1,N);
for i = 1 : N/2+1
    for j = 1:N
        sb(i,j) = sin(2*pi*(i-1)*(j-1)/N);
    end
end
end
