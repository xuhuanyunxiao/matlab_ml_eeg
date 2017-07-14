function [Model,MLresult] = MachineLearning_KNN(MLdata,MLlabel)
% KNN 最邻近规则

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

%% KNN
% 训练集-交叉验证：K值、距离度量方式
KNN_CrossValidation(Train_set,Train_set_label);

% 训练集-构建KNN分类器
model = fitcknn(Train_set,Train_set_label,...
    'NumNeighbors',ML.KNN.CrossValidation.Parameter.BestKvalue,...
    'NSMethod','exhaustive','Distance',ML.KNN.CrossValidation.Parameter.BestDistance);

% 测试集-测试KNN分类器
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
ML.KNN.Result.result = result;
ML.KNN.Result.confusion_matrix = confusion_matrix;
ML.KNN.Result.accuracy = accuracy;
ML.KNN.Result.precision = precision;
ML.KNN.Result.recall = recall;
ML.KNN.Result.Fscore = Fscore;
ML.KNN.Result.TNR = TNR;
ML.KNN.Result.FPR = FPR;
end

function KNN_CrossValidation(Train_set,Train_set_label)
global ML

MinLoss = 1;
BestK = 1; % K值
BestDistance = {};
DistanceName = {'cityblock','chebychev','correlation',...
    'cosine','euclidean','hamming','jaccard','mahalanobis','minkowski','seuclidean','spearman'};
for Dist = 1:length(DistanceName)
    for Kvalue = ML.KNN.CrossValidation.Parameter.Kvalue
        model = fitcknn(Train_set,Train_set_label,'Crossval','on','KFold',5,...
            'NumNeighbors',Kvalue,'NSMethod','exhaustive','Distance',DistanceName{Dist});
        Loss = kfoldLoss(model);
        if Loss < MinLoss
            MinLoss = Loss;
            BestK = Kvalue ;
            BestDistance = DistanceName{Dist};
        end
    end
end
    
ML.KNN.CrossValidation.Parameter.DistanceName = DistanceName;
ML.KNN.CrossValidation.Parameter.BestDistance = BestDistance;
ML.KNN.CrossValidation.Parameter.BestKvalue = BestK;
ML.KNN.CrossValidation.Parameter.MinLoss = MinLoss;

end


