function [PreprocessedFeatureData,PreprocessedFeatureLabel]= MachineLearning_FeaturePreprocessing(data)

global ML
tic
ConditionName = ML.DataDescription.ConditionName;
ConditionNum = ML.Parameter.ConditionNum;
ChannelNum = ML.Parameter.ChannelNum;
feaClean = ML.FeaturePreprocessing.feaClean;
% feaIntegration = ML.FeaturePreprocessing.feaIntegration;
feaReduction = ML.FeaturePreprocessing.feaReduction;
feaTransformation = ML.FeaturePreprocessing.feaTransformation;
% feaIntegration = 0;   % ��������Ƿ�����������ɣ���ͬ����Դ�����ͨ�����ݣ�  (0�����С�1)
% feaClean = 1;  % ��������Ƿ����������ϴ����Ⱥ�㣩  (0�����С�1ֱ��ȥ������Ⱥ�㣨������׼����򣩡�2�滻�ɾ�ֵ��3�滻��)
% feaReduction = 1;   % ��������Ƿ����������Լ����ϡ���ѡ��  (0�����С�1ͳ����ѡ��2��ؼ��)
% feaTransformation = 1;  % ��������Ƿ���������任(0�����С�1�任��[0 1]��2�任��[-1 1]��3��-��ֵ�淶����4С������淶����5�����任)

% ���� FeatureNum
startdata = data.FeatureData;
startlabel = data.FeatureLabel;

XTickLabel = data.ML.FeaturePlot.XTickLabel;
XTickLabels =repmat(XTickLabel,[1 ChannelNum]);

SampleConditionNum = grpstats(startlabel(:,2),startlabel(:,1),{'numel'});
%% 1 ����ж�ͨ�����ݣ����м���
% feaIntegration  % �������ɣ���ͬ���ݼ���
% ��~����~ͨ��������ֵ�ŵ�һ��������
FeatureNum = length(startdata{1,1}(1,:)); % һ��ͨ��������ֵ����
ChannelFeatureMatrixData = zeros(length(startdata(:,1)),FeatureNum);
ChannelFeatureMatrixDatas = [];

for Chan = 1: ChannelNum
    for fileN = 1:length(startdata(:,1))
        ChannelFeatureMatrixData(fileN,1:FeatureNum) = startdata{fileN,Chan}(:);
    end
    ChannelFeatureMatrixDatas = [ChannelFeatureMatrixDatas ChannelFeatureMatrixData];
end

% �ѻ���Ϣ��������� FeatureNum + 1
if ML.Parameter.FeatureType == 3 && ChannelNum>1
    ChannelFeatureMatrixDatas = [ChannelFeatureMatrixDatas cell2mat(startdata(:,ChannelNum+1))];
    % 
    AR_jieshu_n = data.ML.FeaturePlot.AR_jieshu_n;
    XTickLabels = [repmat(XTickLabel(1,1:4+AR_jieshu_n),[1 ChannelNum]) XTickLabel(1,5+AR_jieshu_n:end)];
end
%% 2 ����������Ⱥ�㣩
BadNum = zeros(1,ConditionNum);
switch feaClean   % ����������Ⱥ�㣩
    case 0
        FeatureCleanData = ChannelFeatureMatrixDatas;
        FeatureCleanLabel = startlabel;
    case 1
        FeatureCleanData = []; FeatureCleanLabel = [];
        FeatureNum = length(ChannelFeatureMatrixDatas(1,:)); % �ܹ�����ֵ����        
        for Cond =1:ConditionNum
            CleanData = ChannelFeatureMatrixDatas(startlabel(:,1)==Cond,:);
            CleanLabel = startlabel(startlabel(:,1)==Cond,:);
            FeatureM = mean(CleanData);
            FeatureSD = std(CleanData);
            sigma = 2; % �жϹ���1��������׼������һ����Χ
            UpThreshold = FeatureM + sigma*FeatureSD; % ����
            DownThreshold = FeatureM - sigma*FeatureSD; % ����
            %
            badlabels = [];
            for j = 1:FeatureNum
                badlabel1 = find(CleanData(:,j) <= DownThreshold(1,j));
                badlabel2 = find(CleanData(:,j) >= UpThreshold(1,j));
                badlabels = [badlabels;badlabel1;badlabel2];
            end
            %
            if ~isempty(badlabels)
                tab = tabulate(badlabels);
                BadFrequency = 2; % �жϹ���2��������������������������Χ
                BadLabel = tab(tab(:,2)>BadFrequency,1);
                %
                BadNum(Cond) = length(BadLabel);
                CleanData(BadLabel,:) = [];
                CleanLabel(BadLabel,:) = [];
                FeatureCleanData = [FeatureCleanData;CleanData];
                FeatureCleanLabel = [FeatureCleanLabel;CleanLabel];
            else
                FeatureCleanData = FeatureCleanData;
                FeatureCleanLabel = FeatureCleanLabel;
            end
        end
end

% ����������ʧ��
SampleN1 = length(ChannelFeatureMatrixDatas(:,1)); % ǰ
SampleN2 = length(FeatureCleanData(:,1)); % ��
Title = {'������' '��ʼ������������' '�ж���������Ϊ����' '��ʧ��'};
SampleLoss= [ConditionName' num2cell(SampleConditionNum) num2cell(SampleConditionNum - BadNum') num2cell((BadNum'./SampleConditionNum));...
    '�ܺ�' num2cell(SampleN1) num2cell(SampleN2) num2cell((SampleN1 - SampleN2)/SampleN1)];
SampleLossCondition = [Title;SampleLoss]
ML.FeaturePreprocessing.SampleLossCondition = SampleLossCondition;
%% 3 ������Լ����ϡ���ѡ��
switch feaReduction  % ������Լ����ϡ���ѡ��
    case 0
        FeatureReductionData = FeatureCleanData ;
    case 1 % ͳ�Ƽ�����ѡ���ݣ�������ѡ
        alpha = 0.05;  % ���������ֵ��0.05 0.01 0.001
        k=0;FeatureSig = [];
        for FeaN = 1:FeatureNum
            % ������һԪ�������
            % [h,p] = lillietest(Datai);   % 1 ��̬�Լ��飺����lillietest����
            % [p,stats] = vartestn(log10(Data(:,ii)),Datalabel); % 2 �������Լ��飺����vartestn����
            [p,~,stats] = anova1(FeatureCleanData(:,FeaN),FeatureCleanLabel(:,1),'off'); % 3 �������
            % [c,m,h,gnames] = multcompare(stats); % 4 ���رȽ�
            if p < alpha % ��¼����������Ľ��
                k = k + 1;FeatureSig(1,k)=FeaN;FeatureSig(2,k)=p; % �ڼ�������ֵ��pֵ
            end
        end
        if ~isempty(FeatureSig) % ȡ�����������������
            FeatureReductionData = FeatureCleanData(:,FeatureSig(1,:));
        else
            FeatureReductionData = FeatureCleanData ;
        end
    case 2 % ��ؼ��
        
end
FeatureReductionLabel = FeatureCleanLabel ;

% ����������ʧ��
FeatureNum2 = length(FeatureReductionData(1,:)); % ��
FeatureLoss = {'��ʼ��������' num2str(FeatureNum) ;...
    '������Լ����������' num2str(FeatureNum2);...
    '������ʧ��Ϊ��' num2str((FeatureNum - FeatureNum2)/FeatureNum)}
ML.FeaturePreprocessing.FeatureLoss = FeatureLoss;
ML.FeaturePlot.XTickLabel = XTickLabels;
if exist('FeatureSig','var')
    if ~isempty(FeatureSig)
        disp('��������Ϊ��')
        FeatureRemainName = XTickLabels(1,FeatureSig(1,:))'
        ML.FeaturePreprocessing.FeatureLossName = FeatureRemainName;
        ML.FeaturePlot.XTickLabel = FeatureRemainName;
    end
end
%% 4 �����任
switch feaTransformation   % �����任
    case 0
        FeatureTransformationData = FeatureReductionData ;
    case 1 % �����С����һ������һ���� [0 1]
        FeatureTransformationData = mapminmax(FeatureReductionData',0,1); % ������Ҫת��
        FeatureTransformationData = FeatureTransformationData';
    case 2 % �����С����һ������һ���� [-1 1]
        FeatureTransformationData = mapminmax(FeatureReductionData'); % ������Ҫת��
        FeatureTransformationData = FeatureTransformationData';
    case 3 % ��-��ֵ�淶��
        FeatureTransformationData = zscore(FeatureReductionData);
    case 4 % С������淶��
        max_ = max(abs(FeatureReductionData));
        max_ = power(10,ceil(log10(max_)));
        cols = size(max_,2);
        FeatureTransformationData = FeatureReductionData;
        for i=1:cols
            FeatureTransformationData(:,i)=FeatureReductionData(:,i)/max_(1,i);
        end
    case 5 % ������һ��
        FeatureTransformationData = log10(FeatureReductionData);
end
FeatureTransformationLabel = FeatureReductionLabel ;

%% ������
PreprocessedFeatureData = FeatureTransformationData;
PreprocessedFeatureLabel = FeatureTransformationLabel;
toc
end