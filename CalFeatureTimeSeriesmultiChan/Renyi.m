function RE=Renyi(DataName,N,q)                      
%本函数涉及到三个变量
%DataName--待计算Renyi熵值的信号序列
%N--计算Renyi熵值时所取得的间隔数
%q--计算Renyi熵值时的系数
%q>1时，概率大的子序列在计算中占主导作用
%q<1时，概率小的子序列在计算中占主导作用

x=detrend(DataName);                       %信号先作去趋势处理 
sigma=std(x);                           %求信号标准差
segment=zeros(1,N+1);
for i=-N/2:N/2
    segment(i+N/2+1)=i*3*sigma/N*2;      %以三倍标准差为上下区间划分50等分
end
n=hist(x,segment);                     %按划分的区间作直方图统计
s=sum(n);                                %统计各区间个数求和
p=n/s;                                    %求各区间概率密度
% bar(segment,p);                         %作概率密度分布图

RE=0;                                     %求Renyi熵
for i=1:(N+1)
    RE=p(i)^q+RE;
end
RE=log(RE)/(1-q);
 
