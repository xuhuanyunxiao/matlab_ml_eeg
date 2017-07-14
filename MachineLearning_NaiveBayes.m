function [Model,MLresult] = MachineLearning_NaiveBayes(MLdata,MLlabel)
% ���ر�Ҷ˹���෨ NaiveBayes

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

%% ���ر�Ҷ˹���෨
% ѵ����-������֤����ͬ�ֲ�����ʹ��kernelʱ��kernel����
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

% ѵ����-�������ر�Ҷ˹������
if minIndex < 5
    model = fitcnb(Train_set,Train_set_label,...
        'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{1},...
        'Kernel',ML.NaiveBayes.CrossValidation.KernelTypes{minIndex});
else
    model = fitcnb(Train_set,Train_set_label,...
        'Distribution',ML.NaiveBayes.CrossValidation.DistributionNames{5}); % 5-4+1=2
end

% ���Լ�-�������ر�Ҷ˹������
predict_label = predict(model,Test_set);
Model = model;
Predict_label = predict_label;
    
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
ML.NaiveBayes.Result.result = result;
ML.NaiveBayes.Result.confusion_matrix = confusion_matrix;
ML.NaiveBayes.Result.accuracy = accuracy;
ML.NaiveBayes.Result.precision = precision;
ML.NaiveBayes.Result.recall = recall;
ML.NaiveBayes.Result.Fscore = Fscore;
ML.NaiveBayes.Result.TNR = TNR;
ML.NaiveBayes.Result.FPR = FPR;
end

