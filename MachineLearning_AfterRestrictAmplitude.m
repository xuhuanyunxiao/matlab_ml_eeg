function [AfterRestrictAmplitudeData,AfterRestrictAmplitudeDataLabel, ResAmplitudeResult]= MachineLearning_AfterRestrictAmplitude(data)
% ���޶���ֵ
% AfterRestrictAmplitude

global ML
Amplitude = ML.Parameter.Amplitude;
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;


% ����
PreprocessedDataLabel = data.PreprocessedDataLabel;
PreprocessedData = data.PreprocessedData;
PreprocessedDataFileName = data.ML.RawPreprocessing.PreprocessedDataFileName;

% ��������
[AllFilesNum, gname] = grpstats(PreprocessedDataLabel(:,2),PreprocessedDataLabel(:,1),{'numel' 'gname'});
FilesNum = length(PreprocessedData(:,1));
BadFilesIndex = [];
BadFilesNum = zeros(ConditionNum,ChannelNum);
for Chan = 1:ChannelNum
    bad = 0;
    for num = 1:FilesNum
        eegdata = PreprocessedData{num,Chan};
        if max(abs(eegdata)) >= Amplitude
            BadFilesNum(PreprocessedDataLabel(num,Chan),Chan) = BadFilesNum(PreprocessedDataLabel(num,Chan),Chan) + 1;
            bad = bad +1;
            BadFilesIndex{1,Chan}(bad,1) = num; %  ��¼�ж�Ϊ�����ݵ�λ��
        end
    end
end

% �ϲ�����ͨ��ָʾΪ���ı�ǩ
if ~isempty(BadFilesIndex)
    BadFilesIndexs = [];
    for Chan = 1: ChannelNum
        BadFilesIndexs = [BadFilesIndexs;BadFilesIndex{Chan}];
    end
    BadFilesIndexs1 = unique(BadFilesIndexs);
    % ʶ��ÿ�������¸��ж��ٸ�badfile
    ConBadFiles = PreprocessedDataLabel(BadFilesIndexs1,1);
    for Cond = 1:ConditionNum
        ConBadFilesNum(Cond,1) = length(find(ConBadFiles == Cond));
    end
    %
    PreprocessedDataLabel(BadFilesIndexs1,:)=[]; % ����ж�Ϊ�����ݵ�label
    AfterRestrictAmplitudeDataLabel = PreprocessedDataLabel;
    PreprocessedData(BadFilesIndexs1,:)=[]; % ����ж�Ϊ��������
    AfterRestrictAmplitudeData = PreprocessedData;
    PreprocessedDataFileName(BadFilesIndexs1,:)=[]; % ����ж�Ϊ�����ݵ��ļ���
    ML.RawPreprocessing.AfterRestrictAmplitudeDataFileName = PreprocessedDataFileName;
else
    ConBadFilesNum = zeros(ConditionNum,1);
    AfterRestrictAmplitudeDataLabel = PreprocessedDataLabel;
    AfterRestrictAmplitudeData = PreprocessedData;
    ML.RawPreprocessing.AfterRestrictAmplitudeDataFileName = PreprocessedDataFileName;
end

[NRowX,~]=size(AfterRestrictAmplitudeData);
[NRowY,~]=size(AfterRestrictAmplitudeDataLabel);
if NRowX~=NRowY % ���ݵĸ��� �� ��ǩ�ĸ��� �Ƿ���ͬ
    error('Unequal length of X and Y');
end
%% disp
ChannelDisp = cell(1,ChannelNum);
for Chan = 1: ChannelNum
   ChannelDisp(1,Chan) = {['Channe=' num2str(Chan) ' �ж�Ϊ���ļ���']}; 
end
title = {['Amplitude = ' num2str(Amplitude)] '�ļ�����' ChannelDisp{:} '��ͬΪ���ļ���' '��ʧ��'};
stat = [AllFilesNum(:,1) BadFilesNum ConBadFilesNum ConBadFilesNum./AllFilesNum(:,1)];
Stats = [[ConditionName' num2cell(stat)];...
    ['�ܺ�' num2cell(sum(stat(:,1:end-1))) num2cell(sum(stat(:,end-1))/sum(stat(:,1)))]];
ResAmplitudeResult =[title; Stats]

%
ML.RawPreprocessing.ResAmplitudeResult = ResAmplitudeResult;    

end