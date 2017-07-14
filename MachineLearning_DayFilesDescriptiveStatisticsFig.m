function MachineLearning_DayFilesDescriptiveStatisticsFig(RawDataFileName,RawDataLabel)

global ML
ChannelNum = ML.Parameter.ChannelNum;
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;

% ����������dataset�����ںϲ���
DayFilesDataset(1:ChannelNum,1:ConditionNum) = {dataset({'a'},'VarNames',{'Key'})};
for Chan = 1: ChannelNum
    for Cond=1:ConditionNum
        OneDataFileName = RawDataFileName(RawDataLabel(:,1)==Cond,Chan); % һ������һ��ͨ��
        OneDataFileLabel = RawDataLabel(RawDataLabel(:,1)==Cond,1:2);
        if length(OneDataFileName) ~= length(OneDataFileLabel)
            error('Unequal length of Name and Label');
        end
        nday = 0;
        % DayFilesDataset(Chan,Cond) = {dataset({'a'},1,'VarNames',{'Key' ConditionName{Cond}})};
        for D=1:max(OneDataFileLabel(:,2))
            OneDayFileName = OneDataFileName(OneDataFileLabel(:,2)==D,1); % һ��
            OneDayFileLabel = OneDataFileLabel(OneDataFileLabel(:,2)==D,1:2);
            if ~isempty(OneDayFileLabel)
                nday =nday + 1;
                DayFilesDataset{Chan,Cond}.Key(nday,1) = {OneDayFileName{1}(5:8)};  % ȡ�� ��-��
                eval(['DayFilesDataset{Chan,Cond}.' ConditionName{Cond} '(nday,1) = length(OneDayFileLabel(:,2));']); % ÿ���ļ���
            end
        end
    end
end

% �ϲ����ݣ�ÿ��ͨ���ϸ���������������ͬ����ֻ��ϲ�һ��ͨ������ʾ
FigDayFilesDataset(1,1:ConditionNum) = {dataset({'a'},'VarNames',{'Key'})};
b = 2;
for MergeN = 1:ConditionNum-1
    if MergeN == 1
        FigData1 = join(DayFilesDataset{1,1},DayFilesDataset{1,2},'key','Key','Type','outer','MergeKeys',true);
    else
        b = b+1;
        eval(['FigData' num2str(MergeN) '= join(FigData' num2str(MergeN - 1) ',DayFilesDataset{1,b},''key'',''Key'',''Type'',''outer'',''MergeKeys'',true)' ';']);
    end
end
eval(['FigDayFilesDataset = FigData' num2str(MergeN) ';']);

%% plot
Cond_Num_matrix = dataset2cell(FigDayFilesDataset(:,2:end));  % ������������Ŀ����
Num_matrix = cell2mat(Cond_Num_matrix(2:end,:)); % ������Ŀ����
Num_matrix(isnan(Num_matrix)==1) = -1; % �滻û����ֵ����ΪNaN����Ϊ��ֵ-1
Day_matrix = dataset2cell(FigDayFilesDataset(1:end,1)); % ������

ColorName = {'r','g','b','c','m'};
figure;
disp_cond_num_matrix(1,1) = {'�����������ֱ�Ϊ�� ' };
for Cond=1:ConditionNum
    CondFilesNum = Num_matrix(:,Cond);
    plot(CondFilesNum,ColorName{Cond});
    hold on;
    xlim([0 length(CondFilesNum(:,1))+1]);
    disp_cond_num_matrix(Cond+1,1) = {strcat(Cond_Num_matrix{1,Cond},'��',num2str(sum(Num_matrix(:,Cond))))};
end
hold off;
grid on;
V=axis;
ylim([-2 V(4)]);
set(gca,'XTick',1:1:V(2));
set(gca,'YTick',-2:20:V(4));
set(gca,'XTickLabel',[Day_matrix(2:end,1)',{''}]);
text(V(2)*0.1,V(4)*0.8,disp_cond_num_matrix,'fontsize',20);
hlen=legend(Cond_Num_matrix{1,:});
set(hlen,'FontSize',16);
scnsize = get(0,'MonitorPosition');
set(gcf,'Position',scnsize);


end