function MachineLearning_PlotBox(ConditionChannelMatrixData,FMean,FSD,Chan,TitleName)

global ML

ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
FeatureTypeName = ML.Parameter.FeatureTypeName;
FeatureType = ML.Parameter.FeatureType;

figure;
k = 0;
for Cond = 1:ConditionNum
    %
    k = k+1;
    subplot(ConditionNum,1,k);
    % ��ͼ
    plot(FMean{Cond,Chan},'g-*'); % ��ֵͼ
%     semilogy(FMean{Cond,Chan});
    hold on
    x = FMean{Cond,Chan} + FSD{Cond,Chan}*3;
    y = FMean{Cond,Chan} - FSD{Cond,Chan}*3;
    patch([(1:length(x))';(length(x):-1:1)'],[x';(flipud(y'))],...
        'y','facealpha',0.3,'EdgeColor','g','LineStyle','--');
    hold on
    boxdata = double(ConditionChannelMatrixData{Cond,Chan});
    boxplot(boxdata,'notch','on'); % ��ͼ
    % ����
    ylabel('����','fontsize',18);
    xlabel('Ƶ�� Hz','fontsize',18);
    if k == 1
        title([TitleName;...
            '2-�����ֲ�����';...
            ['  ',ConditionName{Cond} '     Channel=' num2str(Chan)]],...
            'fontsize',18);
    else
        title([FeatureTypeName{FeatureType},...
            '  ',ConditionName{Cond} '     Channel=' num2str(Chan)],'fontsize',18);
    end
    hlen=legend('��ֵ','SD');
    set(hlen,'FontSize',16);
    set(gca,'XTick',1:1:length(FMean{Cond,Chan})+1);
    set(gca,'XTickLabel',{ML.FeaturePlot.XTickLabel{:},''});
    grid on;
    V=axis;
    text(V(2)*0.6,V(4)*0.8,{['��������',num2str(length(boxdata(:,1)))]},'FontSize',16);
    
    scnsize = get(0,'MonitorPosition');
    set(gcf,'Position',scnsize);
    
end
hold off
pause(1)
end