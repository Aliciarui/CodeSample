%实数形式的DFT变换算法
N = 16;%信号长度
xr = round(10*rand(N,1));%随机生生指定长度列向量
xrr=xr'
rdft = zeros(N,1);%初始化
cb = cosbase(N);%获取cos矩阵，DFT基函数
sb = sinbase(N);%获取sin矩阵

ReX = zeros(N/2+1,1);%初始化结果
ImX = zeros(N/2+1,1);

for i = 1 : N/2+1
    ReX(i) = cb(i,:)*xr;%DFT变换，行向量与原始信号列向量相乘
    ImX(i) = sb(i,:)*xr;
end

Re = zeros(N/2+1,1);%还原数组初始化
Im = zeros(N/2+1,1);

%%除首尾之外的计算方式
for i = 1 : N/2 +1
    Re(i) = ReX(i)/(N/2);
    Im(i) = ImX(i)/(N/2);
end

%%对于0和N/2是计算的特殊等式
Re(1) = ReX(1)/N;
Re(N/2+1) = ReX(N/2+1)/N;

yr=zeros(1,N);

for i = 1 : N/2+1
    yr = yr + Re(i)*cb(i,:) + Im(i)*sb(i,:);
end
yr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%复数形式的DFT变换算法
M=8;%指定信号长度
xi = round(10*rand(M,1));%随机生成指定长度列向量
xii=xi'
dftbs = dftbase(M);%复数的DFT基函数形式
rdft = zeros(M,1);%初始化

for k = 1 : M
    rdft(k) = sum(dftbs(k,:)*xi);
end

idft = zeros(M,1);
idftbs = idftbase(M);%复数的IDFT基函数形式

for k = 1 : M
    idft(k) = sum(idftbs(k,:)*rdft)/M;%还原矩阵
end

idft

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%信号去噪声
N2=1024;
t=0:1/(N2-1):1;
fs=N2-1;
n=N2;
xx=50*cos(2*pi*20*t);%生成周期函数
no=30*rand(1,1024);%生成噪声
x=xx+no;%叠加噪声
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

ReX(30:513)=0;%去噪处理，去除低频噪声
ImX(30:513)=0;
%下操作同实数DFT变换
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
