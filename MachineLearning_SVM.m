function [Model,MLresult] = MachineLearning_SVM(MLdata,MLlabel)

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

%% ֧�������� SVM
% ѵ����-������֤������Ѱ�ţ����ز���Ԫ������ѵ��������
SVM_CrossValidation(Train_set,Train_set_label);

% ѵ����-SVM
kernal = ML.SVM.CrossValidation.Parameter.KernelFunction;
gamma = ML.SVM.CrossValidation.Parameter.Gamma;
cost = ML.SVM.CrossValidation.Parameter.Cost;
model = svmtrain(Train_set_label, Train_set, ['-t ',num2str(kernal),' -g ',num2str(gamma),' -c ',num2str(cost)]); % ѵ��    

% ���Լ�-SVM
[Predict_label, ~, ~] = svmpredict(Test_set_label,Test_set, model); % ����

Model = model;
ML.Label.Predict_label = Predict_label;
ML.Label.Test_set_label = Test_set_label;
%% �任���ݲ�����������ͼ:
% MATLAB�Դ�������plotconfusion��plotroc��
if 0
    Test_set_label_c = full(ind2vec(Test_set_label'));
    Predict_label_c = full(ind2vec(Predict_label'));
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

KernelFunction = [1 2 3]; % 1����ʽ�˺�����2 RBF �˺�����3 sigmoid �˺���
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
            accuracy = svmtrain(Train_set, Train_set_label, ParameterPool); % ������֤ģʽ�����һ����ȷ��
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




