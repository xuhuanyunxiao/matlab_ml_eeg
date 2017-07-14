function [PreprocessedData,PreprocessedDataLabel, PreprocessedResult]= MachineLearning_RawPreprocessing(data)
% 20160907
% 20161021
% by xuhuan

% RejArti���Ƿ�Ԥ����1��Ԥ����0����Ԥ����Ĭ��Ϊ1��
% RejChan���Ƿ�ʹ��EEGlab�еĳ���ȥ��ĳ�����õ�txt�ļ�����1��ʹ�ã�0�����ã�Ĭ��Ϊ1��
% threshold��ʹ��RejChanʱ�ı�׼��һ��Ϊ5��Ĭ��Ϊ5��
% RemoveM���Ƿ�ȥ��ֵ��Ĭ��Ϊ1��
% Detr���Ƿ�ȥƯ�ƣ�Ĭ��Ϊ1��
% FIRband���Ƿ��˲�������˲�����Ĭ��Ϊ40Hz��

global ML
tic
% ����
ImportRawData = data.ImportRawData;
ImportRawDataLabel = data.ImportRawDataLabel;
ImportRawDataFileName = data.ML.ImportRawData.ImportRawDataFileName;
clear data

% ����
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;
fs = ML.Parameter.fs;
locutoff = ML.Parameter.locutoff;
hicutoff = ML.RawPreprocessing.hicutoff ;
RejectChannelThreshold = ML.Parameter.RejectChannelThreshold;

% ��������
BadFilesNum = zeros(ConditionNum,ChannelNum);
GoodFilesNum = zeros(ConditionNum,ChannelNum);
AllFilesNum = zeros(ConditionNum,ChannelNum);
PreprocessedData = {};BadFilesIndex = [];

if ML.RawPreprocessing.RejectArtifact  % ����Ԥ����
    for Chan = 1: ChannelNum  % һ��ͨ���������ݣ������жϣ���¼Ϊ���ı�ǩ����¼��ͬͨ���Ļ���ǩ��ֻҪ����һ�ξ�ȥ������
        bad = 0;
        for i = 1:length(ImportRawData(:,1))  % �ļ���
            eegdata = ImportRawData{i,Chan};
            pnts=length(eegdata);  % EEG�ļ��Ĳ�������
            AllFilesNum(ImportRawDataLabel(i,1),Chan) = AllFilesNum(ImportRawDataLabel(i,1),Chan) + 1;
            
            % ����һ��ʹ��eeglab��pop_rejchan�ж�����
            indel = 2;  % �ٶ�Ϊ��
            if ML.RawPreprocessing.RejectChannel
                [~, indelec, ~, ~] = RemovChan(eegdata,RejectChannelThreshold,fs);
                %  EEGdata.data = {measuredata.data};
                if indelec ==1
                    indel =1;  % �ж�Ϊ��
                end
            end
            
            % ��¼�ļ��û�
            if indel==1
                BadFilesNum(ImportRawDataLabel(i,Chan),Chan) = BadFilesNum(ImportRawDataLabel(i,Chan),Chan) + 1;
                bad = bad +1;
                BadFilesIndex{1,Chan}(bad,1) = i; %  ��¼�ж�Ϊ�����ݵ�λ��
            end
            
            % ���˶���С��ȥ��
            if ML.RawPreprocessing.WaveDenoise
                wname = 'db6';
                E = eegdata;
                [C, L]=wavedec(E,5,wname); % ����С��'wname'���ź�X���ж��ֽ�
                [thr,sorh,keepapp]=ddencmp('den','wv',E); %����'ddencmp'�õ������Ĭ�ϲ���
                eegdata=wdencmp('gbl',C,L,wname,5,thr,sorh,keepapp); %ִ�н������
            end
            
            % ��������ȥ��ֵ
            if ML.RawPreprocessing.RemoveMean
                data_1_remove_mean = single(double(eegdata) -mean(double(eegdata)));
            else
                data_1_remove_mean = single(eegdata) ;
            end
            
            % �����ģ�ȥƯ��
            if ML.RawPreprocessing.Detrend
                data_2_detrend.data = detrend(data_1_remove_mean);
            else
                data_2_detrend.data = data_1_remove_mean;
            end
            
            % �����壺�˲�
            if ML.RawPreprocessing.FIRband
                data_2_detrend.srate = fs; % ������
                data_2_detrend.trials = 1; % trial ��
                data_2_detrend.event = [ ]; % trial ��
                data_2_detrend.pnts = pnts; % ��������
                [data_3_FIR, ~, ~] = pop_eegfiltnew(data_2_detrend,locutoff,hicutoff);
                data_3_filter = data_3_FIR.data;
            else
                data_3_filter = data_2_detrend.data;
            end
            
            PreprocessedData(i,Chan) = {double(data_3_filter)};
        end
    end
    
    if ~isempty(BadFilesIndex)
        % �ϲ�����ͨ��ָʾΪ���ı�ǩ
        BadFilesIndexs = [];
        for Chan = 1: ChannelNum
            BadFilesIndexs = [BadFilesIndexs;BadFilesIndex{Chan}];
        end
        BadFilesIndexs1 = unique(BadFilesIndexs);
        % ʶ��ÿ�������¸��ж��ٸ�badfile
        ConBadFiles = ImportRawDataLabel(BadFilesIndexs1,1);
        for Cond = 1:ConditionNum
            ConBadFilesNum(Cond,1) = length(find(ConBadFiles == Cond));
        end
        %
        ImportRawDataLabel(BadFilesIndexs1,:)=[]; % ����ж�Ϊ�����ݵ�label
        PreprocessedDataLabel = ImportRawDataLabel;
        PreprocessedData(BadFilesIndexs1,:)=[]; % ����ж�Ϊ��������
        ImportRawDataFileName(BadFilesIndexs1,:)=[]; % ����ж�Ϊ�����ݵ��ļ���
        ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
    else
        for Cond = 1:ConditionNum
            ConBadFilesNum(Cond,1) = 0;
        end
        PreprocessedDataLabel = ImportRawDataLabel;
        PreprocessedData = PreprocessedData;
        ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
    end
   
else  % ������Ԥ����
    ConBadFilesNum = AllFilesNum(:,1);
    PreprocessedData = ImportRawData;
    PreprocessedDataLabel = ImportRawDataLabel;
    ML.RawPreprocessing.PreprocessedDataFileName = ImportRawDataFileName;
end

[NRowX,~]=size(PreprocessedData);
[NRowY,~]=size(PreprocessedDataLabel);
if NRowX~=NRowY % ���ݵĸ��� �� ��ǩ�ĸ��� �Ƿ���ͬ
    error('Unequal length of X and Y');
end;
%% disp
ChannelDisp = cell(1,ChannelNum);
for Chan = 1: ChannelNum
   ChannelDisp(1,Chan) = {['Channe=' num2str(Chan) ' �ж�Ϊ���ļ���']}; 
end
title = {['threshold = ' num2str(RejectChannelThreshold)] '�ļ�����' ChannelDisp{:} '��ͬΪ���ļ���' '��ʧ��'};
stat = [AllFilesNum(:,1) BadFilesNum ConBadFilesNum ConBadFilesNum./AllFilesNum(:,1)];
Stats = [[ConditionName' num2cell(stat)];...
    ['�ܺ�' num2cell(sum(stat(:,1:end-1))) num2cell(sum(stat(:,end-1))/sum(stat(:,1)))]];
PreprocessedResult =[title; Stats]

%
ML.RawPreprocessing.PreprocessedResult = PreprocessedResult;

toc
end

function [eeg, indelec, measure, com] = RemovChan(data,threshold,fs)
% parameter
a.data= data;
a.srate=fs;
a.nbchan=1;  % һ��ͨ��
a.trials=1;  % һ������
a.setname='s';  % �ļ�����Ҫ�У�������Ҫ
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

% �жϺû�
[eeg, indelec, measure, com] = pop_rejchan( a,'measure','kurt','threshold',threshold);

end

