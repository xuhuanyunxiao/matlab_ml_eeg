function MachineLearning_Plot_M_SE(ConditionChannelMatrixNameNum,FMean,FSE,Chan)

global ML
ConditionNum = ML.Parameter.ConditionNum;
FeatureType = ML.Parameter.FeatureType;
ConditionName = ML.DataDescription.ConditionName;

% ��ɫ����
ColorLine = {'r-','g-*','b-d','c-s','m-p','y-+'};
Color = {'r','g','b','c','m','y'};

figure;
for Cond = 1:ConditionNum
    % ��ͼ
    plot(FMean{Cond,Chan},ColorLine{mod(Cond,6)}); % ��ֵͼ
%     semilogy(FMean{Cond,Chan},ColorLine{mod(Cond,6)});
    hold on
    x = FMean{Cond,Chan} + FSE{Cond,Chan}*3;
    y = FMean{Cond,Chan} - FSE{Cond,Chan}*3;
    patch([(1:length(x))';(length(x):-1:1)'],[x';(flipud(y'))],...
        Color{mod(Cond,6)},'facealpha',0.03,'EdgeColor',Color{Cond},'LineStyle','--');
end

% ����
ylabel('����','fontsize',18);
xlabel('Ƶ�� Hz','fontsize',18);
xlim([0,length(FMean{Cond,Chan})+1]);
set(gca,'XTick',1:1:length(FMean{Cond,Chan})+1);
set(gca,'XTickLabel',{ML.FeaturePlot.XTickLabel{:},''});
V=axis;
text(V(2)*0.1,V(4)*0.9,{'\fontsize{18}��ɫ����������;';...
    '\fontsize{18}ʵ�ߣ���������ֵ;';...
    '\fontsize{18}���ߣ���������׼��'});

text(V(2)*0.6,V(4)*0.8,ConditionChannelMatrixNameNum(:,Chan),'FontSize',16);
% ��ʾ
LegendDetails = cell(1,ConditionNum * 2);
j = 0;
for i = 1:2:ConditionNum * 2 - 1
    j = j+1;
    eval(['LegendDetails(',num2str(i),') = {ConditionName{',num2str(j),'}}',';']);
end
LegendDetails(2:2:end) = {'SE'};
hlen=legend(LegendDetails);
set(hlen,'FontSize',16);

grid on;hold off;

scnsize = get(0,'MonitorPosition');
set(gcf,'Position',scnsize);

end