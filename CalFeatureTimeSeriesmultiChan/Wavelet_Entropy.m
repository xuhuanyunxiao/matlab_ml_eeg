%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Wavelet_Entropy.m
% Function:计算一维时间序列的小波熵
% Author:Dan Liu          
% Time: 2008
%  Usage:
%         >>  Wavelet_Entropy(y,head,tail,step);
%
% y  : 需要计算小波熵的一维向量
% head : ERP开头不需要计算的一段
% tail : ERP的总长度
% step : 小波分解步进长度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wentropy =Wavelet_Entropy(y,head,tail,step)

nsplit=(tail-head-step-mod(tail-head-step,step))/step+1;
decdep=5;%分解深度
for  sp=1:nsplit
    sig=y((sp-1)*step+head+1:(sp-1)*step+head+step);
    wpt=wpdec(sig,decdep,'db6');
    depsize=[5 5 4 3 2 1 ];
    node=[0 1 1 1 1 1];
    for i=1:length(node)
                coef=wpcoef(wpt,[depsize(i) node(i)]);    %返回刺激小波包树[a b]节点的系数
                x=0;
                for l=1:length(coef)
                    x=x+(coef(l)^2);       %每个节点的能量
                end
                s(i)=x;
    end
    toen=sum(s);
    s_norm(sp,:)=s/toen;    %相对小波能量 Pj=Ej/Etot
    wentropy(sp)=0;
    for j=1:length(node)
        wentropy(sp)=wentropy(sp)-s_norm(sp,j)*log(s_norm(sp,j));    %小波熵Swt=-sum(Pj*logPj)
    end     
end