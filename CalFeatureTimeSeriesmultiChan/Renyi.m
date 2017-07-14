function RE=Renyi(DataName,N,q)                      
%�������漰����������
%DataName--������Renyi��ֵ���ź�����
%N--����Renyi��ֵʱ��ȡ�õļ����
%q--����Renyi��ֵʱ��ϵ��
%q>1ʱ�����ʴ���������ڼ�����ռ��������
%q<1ʱ������С���������ڼ�����ռ��������

x=detrend(DataName);                       %�ź�����ȥ���ƴ��� 
sigma=std(x);                           %���źű�׼��
segment=zeros(1,N+1);
for i=-N/2:N/2
    segment(i+N/2+1)=i*3*sigma/N*2;      %��������׼��Ϊ�������仮��50�ȷ�
end
n=hist(x,segment);                     %�����ֵ�������ֱ��ͼͳ��
s=sum(n);                                %ͳ�Ƹ�����������
p=n/s;                                    %�����������ܶ�
% bar(segment,p);                         %�������ܶȷֲ�ͼ

RE=0;                                     %��Renyi��
for i=1:(N+1)
    RE=p(i)^q+RE;
end
RE=log(RE)/(1-q);
 
