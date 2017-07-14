function [Model,MLresult] = MachineLearning_BP(MLdata,MLlabel)

global ML
%% 设置参数
% rng('default'); %
rng(0); % 使用rng之后，每次出现rng(0)，那么随机函数产生的随机数或随机数值都一样。可用rng('shuffle')改变
%% 准备数据
% 所有数据
FeatureData = MLdata; % 输入格式：n*m。 n指样本量，m指特征数
FeatureLabel = MLlabel(:,1); % 输入格式：n*1。  n指样本量

% 转置成神经网络输入格式：m*n。m，特征数；n，样本量。
% FeatureData = FeatureData';
% FeatureLabel = FeatureLabel';

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
Train_set = FeatureData(Train_set_ID,:)'; % 训练集
Test_set = FeatureData(Test_set_ID,:)'; % 测试集
% 分开标签
Train_set_label = FeatureLabel(Train_set_ID,:)'; % 训练集标签
Test_set_label = FeatureLabel(Test_set_ID,:)'; % 测试集标签

Train_set_label_c =ind2vec(Train_set_label); % 训练集标签转换
Test_set_label_c =ind2vec(Test_set_label); % 测试集标签转换

%% BP神经网络
% 训练集-交叉验证：参数寻优（隐藏层神经元个数、训练函数）
BP_CrossValidation(Train_set,Train_set_label_c);

% 训练集-创建BP网络：三层（输入、隐藏、输出）
neuro_num = ML.BP.CrossValidation.Parameter.Best_neuro_num;

if strcmp(ML.BP.NetGenerateFunction,'newff')
    % 构建BP网络
    TF = ML.BP.CrossValidation.Parameter.transferFcn;
    BTF = ML.BP.CrossValidation.Parameter.trainFcn;
    net=newff(Train_set,Train_set_label_c, neuro_num,{TF},BTF);
    % 设置网络参数
    net.trainParam.show = 50;  % 显示训练迭代过程（NaN表示不显示，缺省为25）
    net.trainParam.lr = 0.05;  % 学习率（缺省为0.01）
    net.trainParam.mc = 0.9;  % 动量因子（缺省0.9）
    net.trainParam.epochs = 100;  % 最大训练次数（缺省为10）
    net.trainParam.goal = 1e-3;  % 训练要求精度（缺省为0）    
elseif strcmp(ML.BP.NetGenerateFunction,'feedforwardnet')
    % 构建BP网络
    net = feedforwardnet(neuro_num,ML.BP.CrossValidation.Parameter.trainFcn);
    % 设置网络参数
    net.trainParam.epochs = 100;  % 最大训练次数（缺省为10）
end

% 训练-测试
net=train(net,Train_set,Train_set_label_c); % 训练
% view(net)
Predict_label_c = sim(net,Test_set); % 测试
%
GetResult(Predict_label_c,Test_set_label_c);

Model = net;
Predict_label=vec2ind(Predict_label_c);
ML.Label.Predict_label = Predict_label';
ML.Label.Test_set_label = Test_set_label';

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
ML.BP.Result.result = result;
ML.BP.Result.confusion_matrix = confusion_matrix;
ML.BP.Result.accuracy = accuracy;
ML.BP.Result.precision = precision;
ML.BP.Result.recall = recall;
ML.BP.Result.Fscore = Fscore;
ML.BP.Result.TNR = TNR;
ML.BP.Result.FPR = FPR;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BP_CrossValidation(Train_set,Train_set_label_c)
global ML

ML.BP.CrossValidation.Parameter.accuracy_min = 0;
ML.BP.CrossValidation.Parameter.k_fold=5;
Indices=crossvalind('Kfold',size(Train_set,2),ML.BP.CrossValidation.Parameter.k_fold); % 给出 k 组的标签，用于将原来的训练集划分：训练集（k-1组）、验证集（1组）
ML.BP.CrossValidation.Parameter.Fscore_min=0; % F1 分数
ML.BP.CrossValidation.Parameter.Best_neuro_num=1; % 最佳神经元个数
ML.BP.CrossValidation.Parameter.train_function={}; % 训练函数
ML.BP.CrossValidation.Parameter.transfer_function = {}; % 传递函数
w=0;
h=waitbar(0,'正在寻找最佳神经元个数.....');
for i=1:ML.BP.CrossValidation.Parameter.k_fold
    tic;
    % 分配训练测试集
    Validation_Test_set_ID = (Indices==i); % 交叉测试集标号
    Validation_Train_set_ID = ~Validation_Test_set_ID; % 交叉训练集标号
    Validation_Test_set = Train_set(:,Validation_Test_set_ID); % 交叉测试集
    Validation_Test_set_label_c = Train_set_label_c(:,Validation_Test_set_ID); % 交叉测试集标签
    Validation_Train_set = Train_set(:,Validation_Train_set_ID); % 交叉训练集
    Validation_Train_set_label_c = Train_set_label_c(:,Validation_Train_set_ID); % 交叉训练集标签
    
    % 参数寻优
    for neuro_num = 5%:40 % 神经元个数
        if strcmp(ML.BP.NetGenerateFunction,'newff')
            TrainFunction = {'传递函数为','训练函数为';...
                'tansig','trainlm';'tansig','traingdx';'logsig','trainlm';'logsig','traingdx'};
            for TF = 1%:4
                % 创建BP网络：三层（输入、隐藏、输出）
                ML.BP.CrossValidation.Parameter.transferFcn = TrainFunction{TF+1,1};
                ML.BP.CrossValidation.Parameter.trainFcn = TrainFunction{TF+1,2};
                ML.BP.CrossValidation.Parameter.neuro_num = neuro_num;
                tf = TrainFunction{TF+1,1};
                btf = TrainFunction{TF+1,2};
%                 net=newff(Validation_Train_set,Validation_Train_set_label_c, ML.BP.CrossValidation.Parameter.neuro_num, ...
%                     {ML.BP.CrossValidation.Parameter.transferFcn},{ML.BP.CrossValidation.Parameter.trainFcn});
                net=newff(Validation_Train_set,Validation_Train_set_label_c, ML.BP.CrossValidation.Parameter.neuro_num, ...
                    {tf},btf);                
                % 设置网络参数
                net.trainParam.show = 50;  % 显示训练迭代过程（NaN表示不显示，缺省为25）
                net.trainParam.lr = 0.05;  % 学习率（缺省为0.01）
                net.trainParam.mc = 0.9;  % 动量因子（缺省0.9）
                net.trainParam.epochs = 100;  % 最大训练次数（缺省为10）
                net.trainParam.goal = 1e-3;  % 训练要求精度（缺省为0）
                net=train(net,Validation_Train_set,Validation_Train_set_label_c); % 训练网络
                w=w+1;
                waitbar(w/(5*4*35),h);
                Validation_Predict_label_c = sim(net,Validation_Test_set); % 测试
                %
                GetResult(Validation_Predict_label_c,Validation_Test_set_label_c);
            end
        elseif strcmp(ML.BP.NetGenerateFunction,'feedforwardnet')
            % 有代表性的五种算法为:'traingdx','trainrp','trainscg','trainoss','trainlm'
            TrainFunction = {'traingdx','trainrp','trainscg','trainoss','trainlm'};
            for TF = 1:length(TrainFunction)
                % 构建BP网络
                ML.BP.CrossValidation.Parameter.transferFcn = {};
                ML.BP.CrossValidation.Parameter.trainFcn = TrainFunction{TF};
                ML.BP.CrossValidation.Parameter.neuro_num = neuro_num;
                net = feedforwardnet(ML.BP.CrossValidation.Parameter.neuro_num,ML.BP.CrossValidation.Parameter.trainFcn);
                net.trainParam.epochs = 100;  % 最大训练次数（缺省为10）
                net=train(net,Validation_Train_set,Validation_Train_set_label_c); % 训练
                w=w+1;
                waitbar(w/(5*5*35),h);
                % view(net)
                Validation_Predict_label_c = sim(net,Validation_Test_set); % 测试
                %
                GetResult(Validation_Predict_label_c,Validation_Test_set_label_c);
            end
        end
    end
end

ML.BP.CrossValidation.TrainFunction = TrainFunction;
disp('========= 。。。下面是交叉验证的结果。。。===========================================');
GetParameter(2);

toc;
close(h);

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GetResult(Validation_Predict_label_c,Validation_Test_set_label_c)
global ML

Validation_Predict_label=vec2ind(Validation_Predict_label_c);
Validation_Test_set_label=vec2ind(Validation_Test_set_label_c);
% 计算结果
ML.Label.Predict_label = Validation_Predict_label';
ML.Label.Test_set_label = Validation_Test_set_label';
%
[result,confusion_matrix,accuracy,precision,recall,Fscore,TNR,FPR]= MachineLearning_ComputeMLresult;
ML.BP.CrossValidation.Result.result = result;
ML.BP.CrossValidation.Result.confusion_matrix = confusion_matrix;
ML.BP.CrossValidation.Result.accuracy = accuracy;
ML.BP.CrossValidation.Result.precision = precision;
ML.BP.CrossValidation.Result.recall = recall;
ML.BP.CrossValidation.Result.Fscore = Fscore;
ML.BP.CrossValidation.Result.TNR = TNR;
ML.BP.CrossValidation.Result.FPR = FPR;
%
ChooseParameterAndDisplay;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ChooseParameterAndDisplay
global ML

if ML.BP.CrossValidation.Parameter.Fscore_min == 0
    if ML.BP.CrossValidation.Result.accuracy > ML.BP.CrossValidation.Parameter.accuracy_min
        GetParameter(1);
        ML.BP.CrossValidation.Parameter.flag = {'min(F) = 0'};
        disp('========= 交叉验证--分割线：情况变了 。。。===========================================');
        GetParameter(2);
    end
elseif ML.BP.CrossValidation.Result.Fscore > ML.BP.CrossValidation.Parameter.Fscore_min
    if ML.BP.CrossValidation.Result.accuracy > ML.BP.CrossValidation.Parameter.accuracy_min
        GetParameter(1);
        ML.BP.CrossValidation.Parameter.flag = {'min(F) > 0'};
        disp('========= 交叉验证--分割线：最好的情况出现了  。。。===========================================');
        GetParameter(2);
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GetParameter(status)
global ML

switch status
    case 1
        ML.BP.CrossValidation.Parameter.accuracy_min = ML.BP.CrossValidation.Result.accuracy;
        ML.BP.CrossValidation.Parameter.Fscore_min  = min(ML.BP.CrossValidation.Result.Fscore);
        ML.BP.CrossValidation.Parameter.Best_neuro_num  = ML.BP.CrossValidation.Parameter.neuro_num;
        ML.BP.CrossValidation.Parameter.transfer_function = ML.BP.CrossValidation.Parameter.transferFcn;
        ML.BP.CrossValidation.Parameter.train_function = ML.BP.CrossValidation.Parameter.trainFcn;
        ML.BP.CrossValidation.Parameter.result  = ML.BP.CrossValidation.Result.result;
    case 2
        disp('混淆矩阵为：行和为该条件实际数，列和为该条件预测数');        
        disp([ML.BP.CrossValidation.Parameter.flag;...
            '当前最佳神经元个数为：' num2str(ML.BP.CrossValidation.Parameter.Best_neuro_num); ...
            '  此时总体正确率为：' num2str(ML.BP.CrossValidation.Parameter.accuracy_min);...
            '  传递函数为：' ML.BP.CrossValidation.Parameter.transfer_function;...
            '  训练函数为：' ML.BP.CrossValidation.Parameter.train_function]);
        disp(ML.BP.CrossValidation.Parameter.result);
        
end
end

