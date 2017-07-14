function [Model,MLresult] = MachineLearning_KNN(MLdata,MLlabel)
% KNN ���ڽ�����

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

%% KNN
% ѵ����-������֤��Kֵ�����������ʽ
KNN_CrossValidation(Train_set,Train_set_label);

% ѵ����-����KNN������
model = fitcknn(Train_set,Train_set_label,...
    'NumNeighbors',ML.KNN.CrossValidation.Parameter.BestKvalue,...
    'NSMethod','exhaustive','Distance',ML.KNN.CrossValidation.Parameter.BestDistance);

% ���Լ�-����KNN������
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
BestK = 1; % Kֵ
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


