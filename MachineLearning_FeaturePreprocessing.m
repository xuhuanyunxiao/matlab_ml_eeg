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
% feaIntegration = 0;   % 如果做，是否进行特征集成（不同数据源，如多通道数据）  (0不进行、1)
% feaClean = 1;  % 如果做，是否进行特征清洗（离群点）  (0不进行、1直接去处出离群点（三个标准差规则）、2替换成均值、3替换成)
% feaReduction = 1;   % 如果做，是否进行特征规约（组合、挑选）  (0不进行、1统计挑选、2相关检测)
% feaTransformation = 1;  % 如果做，是否进行特征变换(0不进行、1变换到[0 1]、2变换到[-1 1]、3零-均值规范化、4小数定标规范化、5对数变换)

% 数据 FeatureNum
startdata = data.FeatureData;
startlabel = data.FeatureLabel;

XTickLabel = data.ML.FeaturePlot.XTickLabel;
XTickLabels =repmat(XTickLabel,[1 ChannelNum]);

SampleConditionNum = grpstats(startlabel(:,2),startlabel(:,1),{'numel'});
%% 1 如果有多通道数据，并列集成
% feaIntegration  % 特征集成（不同数据集）
% 将~所有~通道的特征值放到一个矩阵中
FeatureNum = length(startdata{1,1}(1,:)); % 一个通道内特征值个数
ChannelFeatureMatrixData = zeros(length(startdata(:,1)),FeatureNum);
ChannelFeatureMatrixDatas = [];

for Chan = 1: ChannelNum
    for fileN = 1:length(startdata(:,1))
        ChannelFeatureMatrixData(fileN,1:FeatureNum) = startdata{fileN,Chan}(:);
    end
    ChannelFeatureMatrixDatas = [ChannelFeatureMatrixDatas ChannelFeatureMatrixData];
end

% 把互信息放入矩阵内 FeatureNum + 1
if ML.Parameter.FeatureType == 3 && ChannelNum>1
    ChannelFeatureMatrixDatas = [ChannelFeatureMatrixDatas cell2mat(startdata(:,ChannelNum+1))];
    % 
    AR_jieshu_n = data.ML.FeaturePlot.AR_jieshu_n;
    XTickLabels = [repmat(XTickLabel(1,1:4+AR_jieshu_n),[1 ChannelNum]) XTickLabel(1,5+AR_jieshu_n:end)];
end
%% 2 特征清理（离群点）
BadNum = zeros(1,ConditionNum);
switch feaClean   % 特征清理（离群点）
    case 0
        FeatureCleanData = ChannelFeatureMatrixDatas;
        FeatureCleanLabel = startlabel;
    case 1
        FeatureCleanData = []; FeatureCleanLabel = [];
        FeatureNum = length(ChannelFeatureMatrixDatas(1,:)); % 总共特征值个数        
        for Cond =1:ConditionNum
            CleanData = ChannelFeatureMatrixDatas(startlabel(:,1)==Cond,:);
            CleanLabel = startlabel(startlabel(:,1)==Cond,:);
            FeatureM = mean(CleanData);
            FeatureSD = std(CleanData);
            sigma = 2; % 判断规则1：超出标准差上下一定范围
            UpThreshold = FeatureM + sigma*FeatureSD; % 上限
            DownThreshold = FeatureM - sigma*FeatureSD; % 下限
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
                BadFrequency = 2; % 判断规则2：出现两个及以上特征超出范围
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

% 计算样本损失率
SampleN1 = length(ChannelFeatureMatrixDatas(:,1)); % 前
SampleN2 = length(FeatureCleanData(:,1)); % 后
Title = {'条件名' '初始特征样本总数' '判断特征样本为好数' '损失率'};
SampleLoss= [ConditionName' num2cell(SampleConditionNum) num2cell(SampleConditionNum - BadNum') num2cell((BadNum'./SampleConditionNum));...
    '总和' num2cell(SampleN1) num2cell(SampleN2) num2cell((SampleN1 - SampleN2)/SampleN1)];
SampleLossCondition = [Title;SampleLoss]
ML.FeaturePreprocessing.SampleLossCondition = SampleLossCondition;
%% 3 特征规约（组合、挑选）
switch feaReduction  % 特征规约（组合、挑选）
    case 0
        FeatureReductionData = FeatureCleanData ;
    case 1 % 统计检验挑选数据：特征挑选
        alpha = 0.05;  % 方差分析阈值，0.05 0.01 0.001
        k=0;FeatureSig = [];
        for FeaN = 1:FeatureNum
            % 单因素一元方差分析
            % [h,p] = lillietest(Datai);   % 1 正态性检验：调用lillietest函数
            % [p,stats] = vartestn(log10(Data(:,ii)),Datalabel); % 2 方差齐性检验：调用vartestn函数
            [p,~,stats] = anova1(FeatureCleanData(:,FeaN),FeatureCleanLabel(:,1),'off'); % 3 方差分析
            % [c,m,h,gnames] = multcompare(stats); % 4 多重比较
            if p < alpha % 记录有显著差异的结果
                k = k + 1;FeatureSig(1,k)=FeaN;FeatureSig(2,k)=p; % 第几个特征值、p值
            end
        end
        if ~isempty(FeatureSig) % 取出有显著差异的特征
            FeatureReductionData = FeatureCleanData(:,FeatureSig(1,:));
        else
            FeatureReductionData = FeatureCleanData ;
        end
    case 2 % 相关检测
        
end
FeatureReductionLabel = FeatureCleanLabel ;

% 计算特征损失率
FeatureNum2 = length(FeatureReductionData(1,:)); % 后
FeatureLoss = {'初始特征数：' num2str(FeatureNum) ;...
    '特征规约后特征数：' num2str(FeatureNum2);...
    '特征损失率为：' num2str((FeatureNum - FeatureNum2)/FeatureNum)}
ML.FeaturePreprocessing.FeatureLoss = FeatureLoss;
ML.FeaturePlot.XTickLabel = XTickLabels;
if exist('FeatureSig','var')
    if ~isempty(FeatureSig)
        disp('存留特征为：')
        FeatureRemainName = XTickLabels(1,FeatureSig(1,:))'
        ML.FeaturePreprocessing.FeatureLossName = FeatureRemainName;
        ML.FeaturePlot.XTickLabel = FeatureRemainName;
    end
end
%% 4 特征变换
switch feaTransformation   % 特征变换
    case 0
        FeatureTransformationData = FeatureReductionData ;
    case 1 % 最大最小法归一化到归一化到 [0 1]
        FeatureTransformationData = mapminmax(FeatureReductionData',0,1); % 数据需要转置
        FeatureTransformationData = FeatureTransformationData';
    case 2 % 最大最小法归一化到归一化到 [-1 1]
        FeatureTransformationData = mapminmax(FeatureReductionData'); % 数据需要转置
        FeatureTransformationData = FeatureTransformationData';
    case 3 % 零-均值规范化
        FeatureTransformationData = zscore(FeatureReductionData);
    case 4 % 小数定标规范化
        max_ = max(abs(FeatureReductionData));
        max_ = power(10,ceil(log10(max_)));
        cols = size(max_,2);
        FeatureTransformationData = FeatureReductionData;
        for i=1:cols
            FeatureTransformationData(:,i)=FeatureReductionData(:,i)/max_(1,i);
        end
    case 5 % 对数归一化
        FeatureTransformationData = log10(FeatureReductionData);
end
FeatureTransformationLabel = FeatureReductionLabel ;

%% 输出结果
PreprocessedFeatureData = FeatureTransformationData;
PreprocessedFeatureLabel = FeatureTransformationLabel;
toc
end