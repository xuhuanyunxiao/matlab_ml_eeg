function [Model,MLresult] = MachineLearning_DecisionTree(MLdata,MLlabel)
% CART

global ML
%% ���ò���
% rng('default'); %
rng(0); % ʹ��rng֮��ÿ�γ���rng(0)����ô�������������������������ֵ��һ��������rng('shuffle')�ı�
%% ׼������
% ��������
FeatureData = MLdata; % �����ʽ��n*m�� nָ��������mָ������
FeatureLabel = MLlabel(:,1); % �����ʽ��n*1��  nָ������

%% ��������
% ��������
Test_set_rate = 0.1; % ����ѧϰ�����ڲ��Ե����ݸ���:����������10%
Feature_set_num = length(FeatureLabel); % ������������
Train_set_num = ceil(Feature_set_num*(1-Test_set_rate));
% Test_set_num = Feature_set_num - Train_set_num;
% �������
RandomSequence = randperm(Feature_set_num)';% �����������
Train_set_ID = RandomSequence(1:Train_set_num); % ������е�һ������Ϊѵ����
Test_set_ID = RandomSequence(Train_set_num+1:Feature_set_num); % ��һ������Ϊ������
% �ֿ�����
Train_set = FeatureData(Train_set_ID,:); % ѵ����
Test_set = FeatureData(Test_set_ID,:); % ���Լ�
% �ֿ���ǩ
Train_set_label = FeatureLabel(Train_set_ID,:); % ѵ������ǩ
Test_set_label = FeatureLabel(Test_set_ID,:); % ���Լ���ǩ

%% ������ 
% ѵ����-����������
tree = fitctree(Train_set,Train_set_label);
% view(tree,'mode','graph');

% ѵ����-������֤������Ѱ�ţ���ȿ��ƣ�
if ML.DecisionTree.IsPrune  % �Ƿ��֦���������
    [E,SE,Nleaf,BestLevel] = cvloss(tree,'SubTrees','All','KFold',5); % Find the minimum-cost tree
    Tree = prune(tree,'level',BestLevel); % ��֦
    ML.DecisionTree.CrossValidation.E = E;
    ML.DecisionTree.CrossValidation.SE = SE;
    ML.DecisionTree.CrossValidation.Nleaf = Nleaf;
    ML.DecisionTree.CrossValidation.BestLevel = BestLevel;
    
    % ���Լ�-���Ծ�����
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
%% �任���ݲ�����������ͼ:
% MATLAB�Դ�������plotconfusion��plotroc��
if 0
    Test_set_label_c = full(ind2vec(Test_set_label'+1));
    Predict_label_c = full(ind2vec(Predict_label'+1));
    figure;
    plotconfusion(Test_set_label_c,Predict_label_c);
    figure;
    plotroc(Test_set_label_c,Predict_label_c);
end

%% ���ͳ��
[result,confusion_matrix,accuracy,precision,recall,Fscore,TNR,FPR]= MachineLearning_ComputeMLresult;
MLresult = result;

% ������
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

