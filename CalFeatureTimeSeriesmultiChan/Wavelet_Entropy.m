%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Wavelet_Entropy.m
% Function:����һάʱ�����е�С����
% Author:Dan Liu          
% Time: 2008
%  Usage:
%         >>  Wavelet_Entropy(y,head,tail,step);
%
% y  : ��Ҫ����С���ص�һά����
% head : ERP��ͷ����Ҫ�����һ��
% tail : ERP���ܳ���
% step : С���ֽⲽ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wentropy =Wavelet_Entropy(y,head,tail,step)

nsplit=(tail-head-step-mod(tail-head-step,step))/step+1;
decdep=5;%�ֽ����
for  sp=1:nsplit
    sig=y((sp-1)*step+head+1:(sp-1)*step+head+step);
    wpt=wpdec(sig,decdep,'db6');
    depsize=[5 5 4 3 2 1 ];
    node=[0 1 1 1 1 1];
    for i=1:length(node)
                coef=wpcoef(wpt,[depsize(i) node(i)]);    %���ش̼�С������[a b]�ڵ��ϵ��
                x=0;
                for l=1:length(coef)
                    x=x+(coef(l)^2);       %ÿ���ڵ������
                end
                s(i)=x;
    end
    toen=sum(s);
    s_norm(sp,:)=s/toen;    %���С������ Pj=Ej/Etot
    wentropy(sp)=0;
    for j=1:length(node)
        wentropy(sp)=wentropy(sp)-s_norm(sp,j)*log(s_norm(sp,j));    %С����Swt=-sum(Pj*logPj)
    end     
end