function [Model,MLresult] = MachineLearning_DecisionTree(MLdata,MLlabel)
% CART

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

%% 决策树 
% 训练集-构建决策树
tree = fitctree(Train_set,Train_set_label);
% view(tree,'mode','graph');

% 训练集-交叉验证：参数寻优（深度控制）
if ML.DecisionTree.IsPrune  % 是否剪枝，控制深度
    [E,SE,Nleaf,BestLevel] = cvloss(tree,'SubTrees','All','KFold',5); % Find the minimum-cost tree
    Tree = prune(tree,'level',BestLevel); % 剪枝
    ML.DecisionTree.CrossValidation.E = E;
    ML.DecisionTree.CrossValidation.SE = SE;
    ML.DecisionTree.CrossValidation.Nleaf = Nleaf;
    ML.DecisionTree.CrossValidation.BestLevel = BestLevel;
    
    % 测试集-测试决策树
    predict_label_prune = predict(Tree,Test_set);
    Model = Tree;
    Predict_label = predict_label_prune;
else 
    predict_label = predict(tree,Test_set);
    Model = tree;
    Predict_label = predict_label;
end

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
ML.DecisionTree.Result.result = result;
ML.DecisionTree.Result.confusion_matrix = confusion_matrix;
ML.DecisionTree.Result.accuracy = accuracy;
ML.DecisionTree.Result.precision = precision;
ML.DecisionTree.Result.recall = recall;
ML.DecisionTree.Result.Fscore = Fscore;
ML.DecisionTree.Result.TNR = TNR;
ML.DecisionTree.Result.FPR = FPR;
end

