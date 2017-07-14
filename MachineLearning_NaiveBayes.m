function [Model,MLresult] = MachineLearning_NaiveBayes(MLdata,MLlabel)
% 朴素贝叶斯分类法 NaiveBayes

global ML
%% 设置参数
% rng('default'); %
rng(0); % 使用rng之后，每次出现rng(0)，那么随机函数产生的随机数或随机数值都一样。可用rng('shuffle')改变
%% 准备数据
% 所有数据
FeatureData = MLdata; % 输入格式：n*m。 n指样本量，m指特征数
FeatureLabel = MLlabel(:,1); % 输入格式：n*1。  n指样本量

%% 划分数据
% 给定比例
Test_set_rate = 0.1; % 机器学习中用于测试的数据个数:数据总数的10%
Feature_set_num = length(FeatureLabel); % 测试数据总量
Train_set_num = ceil(Feature_set_num*(1-Test_set_rate));
% Test_set_num = Feature_set_num - Train_set_num;
% 随机分组
RandomSequence = randperm(Feature_set_num)';% 产生随机序列
Train_set_ID = RandomSequence(1:Train_set_num); % 随机序列的一部分作为训练组
Test_set_ID = RandomSequence(Train_set_num+1:Feature_set_num); % 另一部分作为测试组
% 分开数据
Train_set = FeatureData(Train_set_ID,:); % 训练集
Test_set = FeatureData(Test_set_ID,:); % 测试集
% 分开标签
Train_set_label = FeatureLabel(Train_set_ID,:); % 训练集标签
Test_set_label = FeatureLabel(Test_set_ID,:); % 测试集标签

%% 朴素贝叶斯分类法
% 训练集-交叉验证：不同分布，当使用kernel时的kernel类型
ML.NaiveBayes.CrossValidation.DistributionNames = {'kernel','normal'};
ML.NaiveBayes.CrossValidation.KernelTypes = {'box','epanechnikov','normal','triangle'};
ML.NaiveBayes.CrossValidation.Loss = zeros(1,5);
for Distri = 1:2
    if Distri == 1
        for KernelN = 1:4
            model = fitcnb(Train_set,Train_set_label,'Crossval','on','KFold',5,...
                'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{Distri},...
                'Kernel',ML.NaiveBayes.CrossValidation.KernelTypes{KernelN});
         
            ML.NaiveBayes.CrossValidation.Loss(1,KernelN) = kfoldLoss(model);
        end
    else
        model = fitcnb(Train_set,Train_set_label,'Crossval','on','KFold',5,...
            'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{Distri});
        
        ML.NaiveBayes.CrossValidation.Loss(1,5) = kfoldLoss(model);        
    end    
end

[minLoss,minIndex] = min(ML.NaiveBayes.CrossValidation.Loss);
ML.NaiveBayes.CrossValidation.minLoss = minLoss;
ML.NaiveBayes.CrossValidation.minIndex = minIndex;

% 训练集-构建朴素贝叶斯分类器
if minIndex < 5
    model = fitcnb(Train_set,Train_set_label,...
        'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{1},...
        'Kernel',ML.NaiveBayes.CrossValidation.KernelTypes{minIndex});
else
    model = fitcnb(Train_set,Train_set_label,...
        'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{5}); % 5-4+1=2
end

% 测试集-测试朴素贝叶斯分类器
predict_label = predict(model,Test_set);
Model = model;
Predict_label = predict_label;
    
ML.Label.Predict_label = Predict_label;
ML.Label.Test_set_label = Test_set_label;
%% 变换数据并画混淆矩阵图:
% MATLAB自带函数（plotconfusion、plotroc）
if 0
    Test_set_label_c = full(ind2vec(Test_set_label'+1));
    Predict_label_c = full(ind2vec(Predict_label'+1));
    figure;
    plotconfusion(Test_set_label_c,Predict_label_c);
    figure;
    plotroc(Test_set_label_c,Predict_label_c);
end

%% 结果统计
[result,confusion_matrix,accuracy,precision,recall,Fscore,TNR,FPR]= MachineLearning_ComputeMLresult;
MLresult = result;

% 结果输出
disp(MLresult)

%
ML.NaiveBayes.Result.result = result;
ML.NaiveBayes.Result.confusion_matrix = confusion_matrix;
ML.NaiveBayes.Result.accuracy = accuracy;
ML.NaiveBayes.Result.precision = precision;
ML.NaiveBayes.Result.recall = recall;
ML.NaiveBayes.Result.Fscore = Fscore;
ML.NaiveBayes.Result.TNR = TNR;
ML.NaiveBayes.Result.FPR = FPR;
end

