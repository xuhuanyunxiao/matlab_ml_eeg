function MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag)
global ML

if nargin < 4
    flag = 1;
end

% ֵ̫����滻�� 
if flag == 1
    [x,y] = find(ConRawDatas{Cond,Chan}(:,:) > 2400 | ConRawDatas{Cond,Chan}(:,:) < -2400);
    ConRawDatas{Cond,Chan}(x,y) = 2400;
end

figure;
% ��άͼ
mesh((1:length(ConRawDatas{Cond,Chan}(1,:))),(1:length(ConRawDatas{Cond,Chan}(:,1))),ConRawDatas{Cond,Chan}(:,:));
% ͼ����Ϣ

ylabel('�ļ���(��)','fontsize',18);
switch flag
    case 1 % �������ݡ�
        xlabel('ʱ�䣨ms��','fontsize',18);
        zlabel('�����΢����','fontsize',18);
%         set(gca,'ZLim',[-200 200]);
%         set(gca,'ZTick',-200:50:200);
        % ��ƽ��
        [x,y]=meshgrid((0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(1,:))):length(ConRawDatas{Cond,Chan}(1,:))),...
            (0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(:,1))):length(ConRawDatas{Cond,Chan}(:,1))));
        z=x*0;z1=x*0-150;z2=x*0+150;
        hold on;surf(x,y,z);
        hold on;surf(x,y,z1);
        hold on;surf(x,y,z2);
        hold off;
        alpha(.1);        
    case 2 % EEGԤ�����޷�
        xlabel('ʱ�䣨ms��','fontsize',18);
        zlabel('�����΢����','fontsize',18);
        set(gca,'ZLim',[-200 200]);
        set(gca,'ZTick',-200:50:200);
        % ��ƽ��
        [x,y]=meshgrid((0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(1,:))):length(ConRawDatas{Cond,Chan}(1,:))),...
            (0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(:,1))):length(ConRawDatas{Cond,Chan}(:,1))));
        z=x*0;z1=x*0-150;z2=x*0+150;
        hold on;surf(x,y,z);
        hold on;surf(x,y,z1);
        hold on;surf(x,y,z2);
        hold off;
        alpha(.1);
    case 3 % EEG����������Ԥ�����
        xlabel('����ֵ','fontsize',18);
        zlabel('����','fontsize',18);  
        xlim([0,length(ConRawDatas{Cond,Chan}(1,:))+1]);
        set(gca,'XTick',1:1:length(ConRawDatas{Cond,Chan}(1,:))+1);
        set(gca,'XTickLabel',{ML.FeaturePlot.XTickLabel{:},''});
end
V=axis;
text(V(2)*0.9,V(4)*0.4,V(6)*0.9,{['��������',num2str(length(ConRawDatas{Cond,Chan}(:,1)))]},'FontSize',16);
view(135,5)
% save
scnsize = get(0,'MonitorPosition');
set(gcf,'Position',scnsize);

end

