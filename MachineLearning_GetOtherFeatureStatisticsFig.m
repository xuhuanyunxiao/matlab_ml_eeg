function MachineLearning_GetOtherFeatureStatisticsFig(ConditionChannelMatrixNameNum,data,Chan,FigName,TitleName,flag)
global ML
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
hicutoff = ML.RawPreprocessing.hicutoff;

% ��ɫ����
ColorLine = {'r-','g-*','b-d','c-s','m-p','y-+'};

figure;
for Cond = 1:ConditionNum
    plot(data{Cond,Chan},ColorLine{mod(Cond,6)},'LineWidth',1); % ��ֵͼ
    hold on;
end
hold off;grid on;
% ����
ylabel('����','fontsize',18);
xlabel('Ƶ�� Hz','fontsize',18);
xlim([0,length(data{Cond,Chan}(1,:))+1]);
set(gca,'XTick',1:1:length(data{Cond,Chan}(1,:))+1);
set(gca,'XTickLabel',{ML.FeaturePlot.XTickLabel{:},''});
V=axis;
text(V(2)*0.1,V(4)*0.9,{'\fontsize{18}��ɫ����ͬ����'});
text(V(2)*0.6,V(4)*0.8,ConditionChannelMatrixNameNum(:,Chan),'FontSize',16);

scnsize = get(0,'MonitorPosition');
set(gcf,'Position',scnsize);

StatisticsName = {' ����ͼ',' ����ͼ',' ����ͼ',' ����ϵ��ͼ',' ƫ��ͼ',' ���ͼ'};
% ��ʾ
LegendDetails = cell(1,ConditionNum);
for i = 1:ConditionNum
    eval(['LegendDetails(',num2str(i),') = {ConditionName{',num2str(i),'}}',';']);
end
hlen=legend(LegendDetails);
set(hlen,'FontSize',16);

title([TitleName;...
    ['  Channel=',num2str(Chan)];...
    [num2str(flag+3),'-��������',StatisticsName{flag}]],...
    'fontsize',18);
% save
saveas(gcf,[FigName,...
   '_channel=',num2str(Chan),'_',num2str(flag+3),'_������',StatisticsName{flag},'.jpg']);

end