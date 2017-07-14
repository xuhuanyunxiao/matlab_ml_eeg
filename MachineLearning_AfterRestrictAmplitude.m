function [AfterRestrictAmplitudeData,AfterRestrictAmplitudeDataLabel, ResAmplitudeResult]= MachineLearning_AfterRestrictAmplitude(data)
% 后限定幅值
% AfterRestrictAmplitude

global ML
Amplitude = ML.Parameter.Amplitude;
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;


% 数据
PreprocessedDataLabel = data.PreprocessedDataLabel;
PreprocessedData = data.PreprocessedData;
PreprocessedDataFileName = data.ML.RawPreprocessing.PreprocessedDataFileName;

% 计算数量
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
            BadFilesIndex{1,Chan}(bad,1) = num; %  记录判断为坏数据的位置
        end
    end
end

% 合并所有通道指示为坏的标签
if ~isempty(BadFilesIndex)
    BadFilesIndexs = [];
    for Chan = 1: ChannelNum
        BadFilesIndexs = [BadFilesIndexs;BadFilesIndex{Chan}];
    end
    BadFilesIndexs1 = unique(BadFilesIndexs);
    % 识别每种条件下各有多少个badfile
    ConBadFiles = PreprocessedDataLabel(BadFilesIndexs1,1);
    for Cond = 1:ConditionNum
        ConBadFilesNum(Cond,1) = length(find(ConBadFiles == Cond));
    end
    %
    PreprocessedDataLabel(BadFilesIndexs1,:)=[]; % 清空判断为坏数据的label
    AfterRestrictAmplitudeDataLabel = PreprocessedDataLabel;
    PreprocessedData(BadFilesIndexs1,:)=[]; % 清空判断为坏的数据
    AfterRestrictAmplitudeData = PreprocessedData;
    PreprocessedDataFileName(BadFilesIndexs1,:)=[]; % 清空判断为坏数据的文件名
    ML.RawPreprocessing.AfterRestrictAmplitudeDataFileName = PreprocessedDataFileName;
else
    ConBadFilesNum = zeros(ConditionNum,1);
    AfterRestrictAmplitudeDataLabel = PreprocessedDataLabel;
    AfterRestrictAmplitudeData = PreprocessedData;
    ML.RawPreprocessing.AfterRestrictAmplitudeDataFileName = PreprocessedDataFileName;
end

[NRowX,~]=size(AfterRestrictAmplitudeData);
[NRowY,~]=size(AfterRestrictAmplitudeDataLabel);
if NRowX~=NRowY % 数据的个数 与 标签的个数 是否相同
    error('Unequal length of X and Y');
end
%% disp
ChannelDisp = cell(1,ChannelNum);
for Chan = 1: ChannelNum
   ChannelDisp(1,Chan) = {['Channe=' num2str(Chan) ' 判断为坏文件数']}; 
end
title = {['Amplitude = ' num2str(Amplitude)] '文件总数' ChannelDisp{:} '共同为坏文件数' '损失率'};
stat = [AllFilesNum(:,1) BadFilesNum ConBadFilesNum ConBadFilesNum./AllFilesNum(:,1)];
Stats = [[ConditionName' num2cell(stat)];...
    ['总和' num2cell(sum(stat(:,1:end-1))) num2cell(sum(stat(:,end-1))/sum(stat(:,1)))]];
ResAmplitudeResult =[title; Stats]

%
ML.RawPreprocessing.ResAmplitudeResult = ResAmplitudeResult;    

end