function [ImportRawData,ImportRawDataLabel] = MachineLearning_ImportRawData

global ML 
tic
ConditionName = ML.DataDescription.ConditionName;
DayName = ML.DataDescription.DayName; 
DataFolder = ML.DataDescription.DataFolder;
ChannelNum = ML.Parameter.ChannelNum;

RawData = {};RawDataLabel =[];
filenum = 0;fileN = 0;
for D=1:length(DayName)
    for C=1:length(ConditionName)
        cd([DataFolder,'\',DayName{D},'\',ConditionName{C}]);
        list=dir([DataFolder,'\',DayName{D},'\',ConditionName{C},'\*.txt']); % 读取当前文件夹下文件        
        if ~isempty(list)
            FileN=length(list); %统计文件个数                       
            for i=1:FileN  % N为每天每种条件下的样本数，即txt文件个数                
                data = load(list(i,1).name); % 导入 txt数据  
                if ChannelNum > 1
                    ChanFlag = str2num(list(i,1).name(16)); % 给文件指定channel标号
                else 
                    ChanFlag = 1;
                end
%                 if strcmp(list(i,1).name(15),'s');
%                     ChanFlag = str2num(list(i,1).name(16));
%                 else
%                     ChanFlag = 1;
%                 end

                filenum = filenum +1;
                if mod(filenum-1,ChannelNum) ==0
                    fileN = fileN +1;
                else 
                    fileN = fileN ;
                end
                RawDataLabel(fileN,:) = [C D i];
                RawData(fileN,ChanFlag) = {data};
                RawDataFilename(fileN,ChanFlag) = {list(i,1).name};
                
            end
        end
    end
end

% 多通道判断采样点是否一致
if ChannelNum > 1
    for i = 1:length(RawData(:,1))
        for j = 1:ChannelNum
            if length(RawData{i,1}) ~= length(RawData{i,j})
                error('Unequal length of channel_A and channel_B');
            end
        end
    end
end

% 输出数据
ImportRawData = RawData;
ImportRawDataLabel = RawDataLabel;
ML.ImportRawData.ImportRawDataFileName = RawDataFilename;

toc
end
