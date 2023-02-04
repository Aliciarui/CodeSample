%%������
rgbimg=imread('lena.jpg');
[r,c,~]=size(rgbimg); %��ȡrbgimg���и�r���п�c
yuvimg=rgb2yuv(rgbimg); %RGBת��ΪYUV
subplot(1,2,1);imshow(rgbimg);

com_img=completion(yuvimg); %��ȫͼ��ʹ�߿���ܱ�16����
[rr,cc,~]=size(com_img); %��ȡ����

[y,u,v]=downsample(com_img); %�²���
[dcty,dctu,dctv]=imgdct(y,u,v); %��ͼ���ӿ���dct�任
[qdcty,qdctu,qdctv]=quantization(dcty,dctu,dctv); %��ͼ���ӿ�����������

yzig=zigzag(qdcty); 
uzig=zigzag(qdctu);
vzig=zigzag(qdctv);

y_dc=dc_dpcm(yzig); %��dcϵ����dpcm����
u_dc=dc_dpcm(uzig);
v_dc=dc_dpcm(vzig);

y_ac=ac_rlc(yzig); %��acϵ����rlc����
u_ac=ac_rlc(uzig);
v_ac=ac_rlc(vzig);

[y_dc2,y_dc_dict]=huffman_encode(y_dc);
[u_dc2,u_dc_dict]=huffman_encode(u_dc);
[v_dc2,v_dc_dict]=huffman_encode(v_dc);
[y_ac2,y_ac_dict]=huffman_encode(y_ac);
[u_ac2,u_ac_dict]=huffman_encode(u_ac);
[v_ac2,v_ac_dict]=huffman_encode(v_ac);

dy_dc=huffman_decode(y_dc2,y_dc_dict);
du_dc=huffman_decode(u_dc2,u_dc_dict);
dv_dc=huffman_decode(v_dc2,v_dc_dict);
dy_ac_back=huffman_decode(y_ac2,y_ac_dict);
du_ac_back=huffman_decode(u_ac2,u_ac_dict);
dv_ac_back=huffman_decode(v_ac2,v_ac_dict);

rdy_ac=rlc_decode(dy_ac_back);
rdu_ac=rlc_decode(du_ac_back);
rdv_ac=rlc_decode(dv_ac_back);

dz_y=zigzag_deco(rdy_ac,rr,dy_dc);
dz_u=zigzag_deco(rdu_ac,rr/2,du_dc);
dz_v=zigzag_deco(rdv_ac,rr/2,dv_dc);

[dqy,dqu,dqv]=dquantization(dz_y,dz_u,dz_v);
[idcty,idctu,idctv]=imgidct(dqy,dqu,dqv);

[u_output,v_output]=upsample(idctu,idctv);
y_output=idcty;

imgimg=zeros(rr,cc,3);%��ʼ��
%��yuvֵ�������ͨ��
imgimg(:,:,1)=y_output;
imgimg(:,:,2)=u_output;
imgimg(:,:,3)=v_output;

[r_output,g_output,b_output,rgb]=yuv2rgb(y_output,u_output,v_output);
img_output=uint8(rgb);
subplot(1,2,2);imshow(img_output);

%%rgb2yuv
function yuv=rgb2yuv(img)
R = img(:,:,1); %Rͨ��
G = img(:,:,2); %Gͨ��
B = img(:,:,3); %ȡBͨ��
%��ʽת��
Y = 0.299 * R + 0.587 * G + 0.114 * B;
U = 128 - 0.168736 * R - 0.331264 * G + 0.5 * B;
V = 128 + 0.5 * R -0.418688 * G - 0.081312 * B; 
yuv=cat(3,Y,U,V); %��������
end

%%ͼ��ȫ
function new_img=completion(img)
[m,n,~]=size(img); 
m_ep=ceil(m/16)*16; %����ȡ����ȡ����С���ܱ�16��������
n_ep=ceil(n/16)*16; %����ȡ����ȡ����С���ܱ�16��������
for i=m+1:m_ep
    img(i,:,:)=img(m,:,:); %�õ�m�в�ȫ
end
for j=n+1:n_ep
    img(:,j,:)=img(:,n,:); %�õ�n�в�ȫ
end
new_img=img; %��ȫ�����ֵ
end

%%4:2:0�²���
function[y,u,v]=downsample(img)
[m,n,~]=size(img); 
y=double(img(:,:,1)); %�������е�ϵ��
u=double(img(1:2:m-1,1:2:n-1,2)); %ȡÿ��2*2���󷽿��еĵ�1��
v=double(img(2:2:m,2:2:n,3)); %ȡÿ��2*2���󷽿��еĵ�2��
end

%%dct�任
function[dcty,dctu,dctv]=imgdct(y,u,v)
%�ָ��8*8С�飬�ֱ���dct�任
dcty=blkproc(y,[8,8],'dct2(x)'); 
dctu=blkproc(u,[8,8],'dct2(x)');
dctv=blkproc(v,[8,8],'dct2(x)');
end

%%����
function[qdcty,qdctu,qdctv]=quantization(y,u,v)
%����������
a=[
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 55;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99;
];
%ɫ�ʲ�������
b=[
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
];
%�ָ��8*8С�飬�ֱ�������
qdcty=blkproc(y,[8,8],'round(x./P1)',a); 
qdctu=blkproc(u,[8,8],'round(x./P1)',b);
qdctv=blkproc(v,[8,8],'round(x./P1)',b);
end

%%ZIGZAG_BLOCK
function [b]=zigzag_block(a)
zigzag_table = [0, 1, 8, 16, 9, 2, 3, 10, ...
    17, 24, 32, 25, 18, 11, 4, 5, ...
    12, 19, 26, 33, 40, 48, 41, 34, ...
    27, 20, 13, 6, 7, 14, 21, 28, ...
    35, 42, 49, 56, 57, 50, 43, 36, ...
    29, 22, 15, 23, 30, 37, 44, 51, ...
    58, 59, 52, 45, 38, 31, 39, 46, ...
    53, 60, 61, 54, 47, 55, 62, 63];
zigzag_table = zigzag_table+1;
aa=reshape(a,1,64); %����Ϊ64�еľ���
b=aa(zigzag_table); %��aa���ղ��ʽȡԪ�أ��õ�ɨ����
end

%%ZIGZAG
function zout=zigzag(zin)
[m,n]=size(zin); 
num=m*n/64; %��ȡ���κ�����
fun=@zigzag_block; %���庯��������������׺���ʱ��ʹ��
tmp=blkproc(zin,[8,8],fun); 
%[m,n]=size(tmp);
tmp=reshape(tmp,num,64); %����Ϊ64�о���
zout=tmp;
end

%%DC_DPCM
function dcout=dc_dpcm(in)
n=size(in,1); %��ȡcin������
dcout=zeros(1,n); %��ʼ��
for i=1:n
    dcout(1,i) = in(i,1); %��ת��
end
dcout=dpcm_encode(dcout); 
end

%%DPCM_encode 
function en = dpcm_encode(f)
n=size(f,2);%%��������
for i=1:n  
    if i==1
        signal(i)=f(i);
    end
    
    if i==2
        signal(i)=f(i);
    end
    if i>2
        sig(i)=0.5*(f(i-1)+f(i-2));
        e(i)=f(i)-sig(i);
        e2(i)=16*fix((255+e(i))/16)-256+8;
        signal(i)=sig(i)+e2(i);
    end
end
en=signal;%%ֱ�ӷ����ع����ź�ֵ
end

%%AC_RLC
function acout=ac_rlc(in)
n=size(in,1);
acout=[]; %��ʼ��
for i=1:n
    acout=[acout;rlc_encode(in(i,:))];%����������еĽ������ƴ��
end
end

%%RLC_encode
function result=rlc_encode(in)
nmax=length(in); %ȡ���������ֵ
result=[]; %��ʼ��resultΪ�վ���

count=0; 
for i=1: nmax
    if in(i)~=0 %������0�����
        result=[result;[count,in(i)]]; %��������ƴ��
        count=0;%���¼���
    else%����0�����
        count=count+1;%����+1
    end
end
result=[result;[0,0]];%00��Ϊ����жϽ����ı�־
end

%%Huffman_encode
function [code,dict]=huffman_encode(data)
[r,c]=size(data); 
new_data=reshape(data,1,r*c); %reshapeΪ1*(r*c)�ľ���
n=length(new_data); %��ȡnew_data���п�
p=[]; %��ʼ��
char=[]; %��ʼ��
for i=1:n
    if find(data(1:i-1)==data(i))
        continue
    else
        count=length(find(data==data(i))); %data(i)���ֵĴ���
        char=[char,data(i)]; %����ƴ��
        p=[p,count/n]; %data(i)���ֵĸ���
    end
end
dict=huffmandict(char,p); %�����ֵ�
%new_data=new_data'; %ת��
code=huffmanenco(new_data,dict); %�����ֵ���huffman����
end

%%huffman����
function code = huffman_decode(enco,dict)
code=huffmandeco(enco,dict);
%code=code';%ת�û�
end

%%RLC_decode
function result=rlc_decode(in)
[r,c]=size(in);
data=reshape(in,r*c/2,2);
temp=[];%��ʼ��
k=0;
for i=1:(r*c/2)
    if(data(i,2)==0)
        while(k<64)
            temp=[temp,0];%��δ����ȥ��0���в�ȫ
            k=k+1;
        end
        k=0;
    else
        j=0;
        while(j<data(i,1))
            temp=[temp,0];%���洢����ĸ������ж�ȡ
            k=k+1;
            j=j+1;
        end
        temp=[temp,data(i,2)];
        k=k+1;
    end
end
[~,n]=size(temp);
num=n/64;
result=reshape(temp,64,num);%�任Ϊ64�еľ���
result=result';%����ת��
end

%%zigzag_deco
function zout=zigzag_deco(zin,rr,dcline)
[m,n]=size(zin);%����rlc_deco��64�о���
[~,f]=size(dcline);
for i=1:f
    turndcline(i,1) = dcline(1,i); %��ת��
end
for i=1:f
    zin(i,1)=turndcline(i,1);
end
row_square=rr/8
col64=m*n/row_square;
temp=reshape(zin,row_square,col64);%���շ���λ�÷���
col=col64/64;
k=1;

dzigzag_table=[
0, 1, 5, 6, 14, 15, 27, 28, ...
2, 4, 7, 13, 16, 26, 29, 42, ...
3, 8, 12, 17, 25, 30, 41, 43, ...
9, 11, 18, 24, 31, 40, 44, 53, ...
10, 19, 23, 32, 39, 45, 52, 54, ...
20, 22, 33, 38, 46, 41, 55, 60, ...
21, 34, 37, 47, 50, 56, 59, 61, ...
35, 36, 48, 49, 57, 58, 62, 63];

dzigzag_table = dzigzag_table + 1;%�����±����
zouttmp=[];%��ʼ��
zout=[];%��ʼ��
for i=1:row_square
    for j=1:col
        dstart=(j-1)*64+1;
        dend=dstart+63;
        a=temp(i,dstart:dend);%aΪĳ��1*64����
        aa=a(dzigzag_table);%����a�ķ�ʽȡԪ��
        dzig_block=reshape(aa,8,8);
        zouttmp=[zouttmp,dzig_block];
    end
    zout=[zout;zouttmp];
    zouttmp=[];
end
end

%%������
function[dqy,dqu,dqv]=dquantization(y,u,v)
%����������
a=[
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 55;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99;
];
%ɫ�ʲ�������
b=[
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
];
dqy=blkproc(y,[8,8],'round(x.*P1)',a); %#ok<*DBLKPRC> %��ͼ�����8*8�ֿ飬����ÿһ������������
dqu=blkproc(u,[8,8],'round(x.*P1)',b);
dqv=blkproc(v,[8,8],'round(x.*P1)',b);
end

%%idct�任
function[dcty,dctu,dctv]=imgidct(y,u,v)
dcty=blkproc(y,[8,8],'idct2(x)'); %��ͼ�����8*8�ֿ鴦������ÿһ������άdct�任
dctu=blkproc(u,[8,8],'idct2(x)');
dctv=blkproc(v,[8,8],'idct2(x)');
end

%%4:2:0�ϲ���
function [uout,vout] = upsample(u,v)
uout=kron(u,[1,1;1,1]);%��ÿ����ֵ����Ϊ2*2����
vout=kron(v,[1,1;1,1]);
end

function [R,G,B,rgb] = yuv2rgb(Y,U,V)
%���ݹ�ʽyuvתrgb
R = Y + 1.402.*(V-128);
G = Y - 0.34414.*(U-128) - 0.71414.*(V-128);
B = Y + 1.772.*(U-128); 
rgb=cat(3,R,G,B); %��������
end