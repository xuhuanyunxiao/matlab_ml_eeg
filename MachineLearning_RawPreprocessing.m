function [PreprocessedData,PreprocessedDataLabel, PreprocessedResult]= MachineLearning_RawPreprocessing(data)
% 20160907
% 20161021
% by xuhuan

% RejArti：是否预处理，1，预处理；0，不预处理（默认为1）
% RejChan：是否使用EEGlab中的程序去除某个不好的txt文件——1，使用；0，不用（默认为1）
% threshold：使用RejChan时的标准，一般为5（默认为5）
% RemoveM：是否去均值（默认为1）
% Detr：是否去漂移（默认为1）
% FIRband：是否滤波，如果滤波，（默认为40Hz）

global ML
tic
% 数据
ImportRawData = data.ImportRawData;
ImportRawDataLabel = data.ImportRawDataLabel;
ImportRawDataFileName = data.ML.ImportRawData.ImportRawDataFileName;
clear data

% 参数
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;
fs = ML.Parameter.fs;
locutoff = ML.Parameter.locutoff;
hicutoff = ML.RawPreprocessing.hicutoff ;
RejectChannelThreshold = ML.Parameter.RejectChannelThreshold;

% 建立变量
BadFilesNum = zeros(ConditionNum,ChannelNum);
GoodFilesNum = zeros(ConditionNum,ChannelNum);
AllFilesNum = zeros(ConditionNum,ChannelNum);
PreprocessedData = {};BadFilesIndex = [];

if ML.RawPreprocessing.RejectArtifact  % 进行预处理
    for Chan = 1: ChannelNum  % 一个通道所有数据，进行判断，记录为坏的标签。记录不同通道的坏标签，只要出现一次就去除数据
        bad = 0;
        for i = 1:length(ImportRawData(:,1))  % 文件数
            eegdata = ImportRawData{i,Chan};
            pnts=length(eegdata);  % EEG文件的采样点数
            AllFilesNum(ImportRawDataLabel(i,1),Chan) = AllFilesNum(ImportRawDataLabel(i,1),Chan) + 1;
            
            % 过滤一：使用eeglab中pop_rejchan判断数据
            indel = 2;  % 假定为好
            if ML.RawPreprocessing.RejectChannel
                [~, indelec, ~, ~] = RemovChan(eegdata,RejectChannelThreshold,fs);
                %  EEGdata.data = {measuredata.data};
                if indelec ==1
                    indel =1;  % 判断为坏
                end
            end
            
            % 记录文件好坏
            if indel==1
                BadFilesNum(ImportRawDataLabel(i,Chan),Chan) = BadFilesNum(ImportRawDataLabel(i,Chan),Chan) + 1;
                bad = bad +1;
                BadFilesIndex{1,Chan}(bad,1) = i; %  记录判断为坏数据的位置
            end
            
            % 过滤二：小波去噪
            if ML.RawPreprocessing.WaveDenoise
                wname = 'db6';
                E = eegdata;
                [C, L]=wavedec(E,5,wname); % 利用小波'wname'对信号X进行多层分解
                [thr,sorh,keepapp]=ddencmp('den','wv',E); %利用'ddencmp'得到除噪的默认参数
                eegdata=wdencmp('gbl',C,L,wname,5,thr,sorh,keepapp); %执行降噪操作
            end
            
            % 过滤三：去均值
            if ML.RawPreprocessing.RemoveMean
                data_1_remove_mean = single(double(eegdata) -mean(double(eegdata)));
            else
                data_1_remove_mean = single(eegdata) ;
            end
            
            % 过滤四：去漂移
            if ML.RawPreprocessing.Detrend
                data_2_detrend.data = detrend(data_1_remove_mean);
            else
                data_2_detrend.data = data_1_remove_mean;
            end
            
            % 过滤五：滤波
            if ML.RawPreprocessing.FIRband
                data_2_detrend.srate = fs; % 采样率
                data_2_detrend.trials = 1; % trial 数
                data_2_detrend.event = [ ]; % trial 数
                data_2_detrend.pnts = pnts; % 采样点数
                [data_3_FIR, ~, ~] = pop_eegfiltnew(data_2_detrend,locutoff,hicutoff);
                data_3_filter = data_3_FIR.data;
            else
                data_3_filter = data_2_detrend.data;
            end
            
            PreprocessedData(i,Chan) = {double(data_3_filter)};
        end
    end
    
    if ~isempty(BadFilesIndex)
        % 合并所有通道指示为坏的标签
        BadFilesIndexs = [];
        for Chan = 1: ChannelNum
            BadFilesIndexs = [BadFilesIndexs;BadFilesIndex{Chan}];
        end
        BadFilesIndexs1 = unique(BadFilesIndexs);
        % 识别每种条件下各有多少个badfile
        ConBadFiles = ImportRawDataLabel(BadFilesIndexs1,1);
        for Cond = 1:ConditionNum
            ConBadFilesNum(Cond,1) = length(find(ConBadFiles == Cond));
        end
        %
        ImportRawDataLabel(BadFilesIndexs1,:)=[]; % 清空判断为坏数据的label
        PreprocessedDataLabel = ImportRawDataLabel;
        PreprocessedData(BadFilesIndexs1,:)=[]; % 清空判断为坏的数据
        ImportRawDataFileName(BadFilesIndexs1,:)=[]; % 清空判断为坏数据的文件名
        ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
    else
        for Cond = 1:ConditionNum
            ConBadFilesNum(Cond,1) = 0;
        end
        PreprocessedDataLabel = ImportRawDataLabel;
        PreprocessedData = PreprocessedData;
        ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
    end
   
else  % 不进行预处理
    ConBadFilesNum = AllFilesNum(:,1);
    PreprocessedData = ImportRawData;
    PreprocessedDataLabel = ImportRawDataLabel;
    ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
end

[NRowX,~]=size(PreprocessedData);
[NRowY,~]=size(PreprocessedDataLabel);
if NRowX~=NRowY % 数据的个数 与 标签的个数 是否相同
    error('Unequal length of X and Y');
end;
%% disp
ChannelDisp = cell(1,ChannelNum);
for Chan = 1: ChannelNum
   ChannelDisp(1,Chan) = {['Channe=' num2str(Chan) ' 判断为坏文件数']}; 
end
title = {['threshold = ' num2str(RejectChannelThreshold)] '文件总数' ChannelDisp{:} '共同为坏文件数' '损失率'};
stat = [AllFilesNum(:,1) BadFilesNum ConBadFilesNum ConBadFilesNum./AllFilesNum(:,1)];
Stats = [[ConditionName' num2cell(stat)];...
    ['总和' num2cell(sum(stat(:,1:end-1))) num2cell(sum(stat(:,end-1))/sum(stat(:,1)))]];
PreprocessedResult =[title; Stats]

%
ML.RawPreprocessing.PreprocessedResult = PreprocessedResult;

toc
end

function [eeg, indelec, measure, com] = RemovChan(data,threshold,fs)
% parameter
a.data= data;
a.srate=fs;
a.nbchan=1;  % 一个通道
a.trials=1;  % 一段数据
a.setname='s';  % 文件名，要有，但不重要
a.xmax=length(data)/fs;
a.xmin=0;

a.chanlocs=[];
a.etc=[];
a.icaact=[];
a.icachansind=[];
a.icasphere=[];
a.icawinv=[];
a.icaweights=[];
a.specdata=[];
a.specicaact=[];
a.epoch=[];
a.event=[];

% 判断好坏
[eeg, indelec, measure, com] = pop_rejchan( a,'measure','kurt','threshold',threshold);

end

