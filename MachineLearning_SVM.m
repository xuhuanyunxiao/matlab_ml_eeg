function [Model,MLresult] = MachineLearning_SVM(MLdata,MLlabel)

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

%% 支持向量机 SVM
% 训练集-交叉验证：参数寻优（隐藏层神经元个数、训练函数）
SVM_CrossValidation(Train_set,Train_set_label);

% 训练集-SVM
kernal = ML.SVM.CrossValidation.Parameter.KernelFunction;
gamma = ML.SVM.CrossValidation.Parameter.Gamma;
cost = ML.SVM.CrossValidation.Parameter.Cost;
model = svmtrain(Train_set_label, Train_set, ['-t ',num2str(kernal),' -g ',num2str(gamma),' -c ',num2str(cost)]); % 训练    

% 测试集-SVM
[Predict_label, ~, ~] = svmpredict(Test_set_label,Test_set, model); % 测试

Model = model;
ML.Label.Predict_label = Predict_label;
ML.Label.Test_set_label = Test_set_label;
%% 变换数据并画混淆矩阵图:
% MATLAB自带函数（plotconfusion、plotroc）
if 0
    Test_set_label_c = full(ind2vec(Test_set_label'));
    Predict_label_c = full(ind2vec(Predict_label'));
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
ML.SVM.Result.result = result;
ML.SVM.Result.confusion_matrix = confusion_matrix;
ML.SVM.Result.accuracy = accuracy;
ML.SVM.Result.precision = precision;
ML.SVM.Result.recall = recall;
ML.SVM.Result.Fscore = Fscore;
ML.SVM.Result.TNR = TNR;
ML.SVM.Result.FPR = FPR;
end

function SVM_CrossValidation(Train_set,Train_set_label)
global ML

KernelFunction = [1 2 3]; % 1多项式核函数；2 RBF 核函数；3 sigmoid 核函数
g_min = -8;g_max = 8;g_setp = 1;
g = g_min:g_setp:g_max;Gamma = zeros(size(g));
for gg =1 :length(g)
    Gamma(gg) = 2^(g(gg));
end
c_min = -8;c_max = 8;c_setp = 1;
c = c_min:c_setp:c_max;Cost = zeros(size(c));
for cc =1 :length(c)
    Cost(cc) =  2^(c(cc));
end

BestAccuracy = 0;
BestK = 1;
BestG = 1;
BestC = 1;
BestParameterPool = [];
a = 0;
for K = 1:length(KernelFunction) 
    for G = 1:length(Gamma)
        for C = 1:length(Cost)
%             ParameterPool = ['-t 2 -v 5 -g 0.1 -c 1'];
            ParameterPool = ['-t ',num2str(K),' -v 5 -g ',num2str(Gamma(G)),' -c ',num2str(Cost(C))];
            accuracy = svmtrain(Train_set, Train_set_label, ParameterPool); % 交叉验证模式下输出一个正确率
            if accuracy > BestAccuracy
                BestAccuracy = accuracy;
                BestK = K;
                BestG = Gamma(G);
                BestC = Cost(C);
                BestParameterPool = ParameterPool;
                a = a+1;
                ACC(a,1:4) = [K G C accuracy];
                pause(1)
                disp({['K=' num2str(K) ];['G='  num2str(G)];['C='  num2str(C)];['ACC=' num2str(accuracy)]})
            end
        end
    end
end

ML.SVM.CrossValidation.Parameter.KernelFunction = BestK;
ML.SVM.CrossValidation.Parameter.Gamma = BestG;
ML.SVM.CrossValidation.Parameter.Cost = BestC;
ML.SVM.CrossValidation.Parameter.ParameterPool = BestParameterPool;

end




