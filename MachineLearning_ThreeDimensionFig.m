function MachineLearning_ThreeDimensionFig(ConRawDatas,Chan,Cond,flag)
global ML

if nargin < 4
    flag = 1;
end

% 值太大的替换掉 
if flag == 1
    [x,y] = find(ConRawDatas{Cond,Chan}(:,:) > 2400 | ConRawDatas{Cond,Chan}(:,:) < -2400);
    ConRawDatas{Cond,Chan}(x,y) = 2400;
end

figure;
% 三维图
mesh((1:length(ConRawDatas{Cond,Chan}(1,:))),(1:length(ConRawDatas{Cond,Chan}(:,1))),ConRawDatas{Cond,Chan}(:,:));
% 图像信息

ylabel('文件数(个)','fontsize',18);
switch flag
    case 1 % 导入数据、
        xlabel('时间（ms）','fontsize',18);
        zlabel('振幅（微伏）','fontsize',18);
%         set(gca,'ZLim',[-200 200]);
%         set(gca,'ZTick',-200:50:200);
        % 加平面
        [x,y]=meshgrid((0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(1,:))):length(ConRawDatas{Cond,Chan}(1,:))),...
            (0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(:,1))):length(ConRawDatas{Cond,Chan}(:,1))));
        z=x*0;z1=x*0-150;z2=x*0+150;
        hold on;surf(x,y,z);
        hold on;surf(x,y,z1);
        hold on;surf(x,y,z2);
        hold off;
        alpha(.1);        
    case 2 % EEG预处理、限幅
        xlabel('时间（ms）','fontsize',18);
        zlabel('振幅（微伏）','fontsize',18);
        set(gca,'ZLim',[-200 200]);
        set(gca,'ZTick',-200:50:200);
        % 加平面
        [x,y]=meshgrid((0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(1,:))):length(ConRawDatas{Cond,Chan}(1,:))),...
            (0:ceil(0.1 * length(ConRawDatas{Cond,Chan}(:,1))):length(ConRawDatas{Cond,Chan}(:,1))));
        z=x*0;z1=x*0-150;z2=x*0+150;
        hold on;surf(x,y,z);
        hold on;surf(x,y,z1);
        hold on;surf(x,y,z2);
        hold off;
        alpha(.1);
    case 3 % EEG特征、特征预处理后
        xlabel('特征值','fontsize',18);
        zlabel('能量','fontsize',18);  
        xlim([0,length(ConRawDatas{Cond,Chan}(1,:))+1]);
        set(gca,'XTick',1:1:length(ConRawDatas{Cond,Chan}(1,:))+1);
        set(gca,'XTickLabel',{ML.FeaturePlot.XTickLabel{:},''});
end
V=axis;
text(V(2)*0.9,V(4)*0.4,V(6)*0.9,{['数据量：',num2str(length(ConRawDatas{Cond,Chan}(:,1)))]},'FontSize',16);
view(135,5)
% save
scnsize = get(0,'MonitorPosition');
set(gcf,'Position',scnsize);

end

