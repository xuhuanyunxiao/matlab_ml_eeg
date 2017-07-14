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
        list=dir([DataFolder,'\',DayName{D},'\',ConditionName{C},'\*.txt']); % ��ȡ��ǰ�ļ������ļ�        
        if ~isempty(list)
            FileN=length(list); %ͳ���ļ�����                       
            for i=1:FileN  % NΪÿ��ÿ�������µ�����������txt�ļ�����                
                data = load(list(i,1).name); % ���� txt����  
                if ChannelNum > 1
                    ChanFlag = str2num(list(i,1).name(16)); % ���ļ�ָ��channel���
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

% ��ͨ���жϲ������Ƿ�һ��
if ChannelNum > 1
    for i = 1:length(RawData(:,1))
        for j = 1:ChannelNum
            if length(RawData{i,1}) ~= length(RawData{i,j})
                error('Unequal length of channel_A and channel_B');
            end
        end
    end
end

% �������
ImportRawData = RawData;
ImportRawDataLabel = RawDataLabel;
ML.ImportRawData.ImportRawDataFileName = RawDataFilename;

toc
end
