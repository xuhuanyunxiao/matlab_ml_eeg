function [Model,MLresult] = MachineLearning_BP(MLdata,MLlabel)

global ML
%% ���ò���
% rng('default'); %
rng(0); % ʹ��rng֮��ÿ�γ���rng(0)����ô�������������������������ֵ��һ��������rng('shuffle')�ı�
%% ׼������
% ��������
FeatureData = MLdata; % �����ʽ��n*m�� nָ��������mָ������
FeatureLabel = MLlabel(:,1); % �����ʽ��n*1��  nָ������

% ת�ó������������ʽ��m*n��m����������n����������
% FeatureData = FeatureData';
% FeatureLabel = FeatureLabel';

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
Train_set = FeatureData(Train_set_ID,:)'; % ѵ����
Test_set = FeatureData(Test_set_ID,:)'; % ���Լ�
% �ֿ���ǩ
Train_set_label = FeatureLabel(Train_set_ID,:)'; % ѵ������ǩ
Test_set_label = FeatureLabel(Test_set_ID,:)'; % ���Լ���ǩ

Train_set_label_c =ind2vec(Train_set_label); % ѵ������ǩת��
Test_set_label_c =ind2vec(Test_set_label); % ���Լ���ǩת��

%% BP������
% ѵ����-������֤������Ѱ�ţ����ز���Ԫ������ѵ��������
BP_CrossValidation(Train_set,Train_set_label_c);

% ѵ����-����BP���磺���㣨���롢���ء������
neuro_num = ML.BP.CrossValidation.Parameter.Best_neuro_num;

if strcmp(ML.BP.NetGenerateFunction,'newff')
    % ����BP����
    TF = ML.BP.CrossValidation.Parameter.transferFcn;
    BTF = ML.BP.CrossValidation.Parameter.trainFcn;
    net=newff(Train_set,Train_set_label_c, neuro_num,{TF},BTF);
    % �����������
    net.trainParam.show = 50;  % ��ʾѵ���������̣�NaN��ʾ����ʾ��ȱʡΪ25��
    net.trainParam.lr = 0.05;  % ѧϰ�ʣ�ȱʡΪ0.01��
    net.trainParam.mc = 0.9;  % �������ӣ�ȱʡ0.9��
    net.trainParam.epochs = 100;  % ���ѵ��������ȱʡΪ10��
    net.trainParam.goal = 1e-3;  % ѵ��Ҫ�󾫶ȣ�ȱʡΪ0��    
elseif strcmp(ML.BP.NetGenerateFunction,'feedforwardnet')
    % ����BP����
    net = feedforwardnet(neuro_num,ML.BP.CrossValidation.Parameter.trainFcn);
    % �����������
    net.trainParam.epochs = 100;  % ���ѵ��������ȱʡΪ10��
end

% ѵ��-����
net=train(net,Train_set,Train_set_label_c); % ѵ��
% view(net)
Predict_label_c = sim(net,Test_set); % ����
%
GetResult(Predict_label_c,Test_set_label_c);

Model = net;
Predict_label=vec2ind(Predict_label_c);
ML.Label.Predict_label = Predict_label';
ML.Label.Test_set_label = Test_set_label';

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
Indices=crossvalind('Kfold',size(Train_set,2),ML.BP.CrossValidation.Parameter.k_fold); % ���� k ��ı�ǩ�����ڽ�ԭ����ѵ�������֣�ѵ������k-1�飩����֤����1�飩
ML.BP.CrossValidation.Parameter.Fscore_min=0; % F1 ����
ML.BP.CrossValidation.Parameter.Best_neuro_num=1; % �����Ԫ����
ML.BP.CrossValidation.Parameter.train_function={}; % ѵ������
ML.BP.CrossValidation.Parameter.transfer_function = {}; % ���ݺ���
w=0;
h=waitbar(0,'����Ѱ�������Ԫ����.....');
for i=1:ML.BP.CrossValidation.Parameter.k_fold
    tic;
    % ����ѵ�����Լ�
    Validation_Test_set_ID = (Indices==i); % ������Լ����
    Validation_Train_set_ID = ~Validation_Test_set_ID; % ����ѵ�������
    Validation_Test_set = Train_set(:,Validation_Test_set_ID); % ������Լ�
    Validation_Test_set_label_c = Train_set_label_c(:,Validation_Test_set_ID); % ������Լ���ǩ
    Validation_Train_set = Train_set(:,Validation_Train_set_ID); % ����ѵ����
    Validation_Train_set_label_c = Train_set_label_c(:,Validation_Train_set_ID); % ����ѵ������ǩ
    
    % ����Ѱ��
    for neuro_num = 5%:40 % ��Ԫ����
        if strcmp(ML.BP.NetGenerateFunction,'newff')
            TrainFunction = {'���ݺ���Ϊ','ѵ������Ϊ';...
                'tansig','trainlm';'tansig','traingdx';'logsig','trainlm';'logsig','traingdx'};
            for TF = 1%:4
                % ����BP���磺���㣨���롢���ء������
                ML.BP.CrossValidation.Parameter.transferFcn = TrainFunction{TF+1,1};
                ML.BP.CrossValidation.Parameter.trainFcn = TrainFunction{TF+1,2};
                ML.BP.CrossValidation.Parameter.neuro_num = neuro_num;
                tf = TrainFunction{TF+1,1};
                btf = TrainFunction{TF+1,2};
%                 net=newff(Validation_Train_set,Validation_Train_set_label_c, ML.BP.CrossValidation.Parameter.neuro_num, ...
%                     {ML.BP.CrossValidation.Parameter.transferFcn},{ML.BP.CrossValidation.Parameter.trainFcn});
                net=newff(Validation_Train_set,Validation_Train_set_label_c, ML.BP.CrossValidation.Parameter.neuro_num, ...
                    {tf},btf);                
                % �����������
                net.trainParam.show = 50;  % ��ʾѵ���������̣�NaN��ʾ����ʾ��ȱʡΪ25��
                net.trainParam.lr = 0.05;  % ѧϰ�ʣ�ȱʡΪ0.01��
                net.trainParam.mc = 0.9;  % �������ӣ�ȱʡ0.9��
                net.trainParam.epochs = 100;  % ���ѵ��������ȱʡΪ10��
                net.trainParam.goal = 1e-3;  % ѵ��Ҫ�󾫶ȣ�ȱʡΪ0��
                net=train(net,Validation_Train_set,Validation_Train_set_label_c); % ѵ������
                w=w+1;
                waitbar(w/(5*4*35),h);
                Validation_Predict_label_c = sim(net,Validation_Test_set); % ����
                %
                GetResult(Validation_Predict_label_c,Validation_Test_set_label_c);
            end
        elseif strcmp(ML.BP.NetGenerateFunction,'feedforwardnet')
            % �д����Ե������㷨Ϊ:'traingdx','trainrp','trainscg','trainoss','trainlm'
            TrainFunction = {'traingdx','trainrp','trainscg','trainoss','trainlm'};
            for TF = 1:length(TrainFunction)
                % ����BP����
                ML.BP.CrossValidation.Parameter.transferFcn = {};
                ML.BP.CrossValidation.Parameter.trainFcn = TrainFunction{TF};
                ML.BP.CrossValidation.Parameter.neuro_num = neuro_num;
                net = feedforwardnet(ML.BP.CrossValidation.Parameter.neuro_num,ML.BP.CrossValidation.Parameter.trainFcn);
                net.trainParam.epochs = 100;  % ���ѵ��������ȱʡΪ10��
                net=train(net,Validation_Train_set,Validation_Train_set_label_c); % ѵ��
                w=w+1;
                waitbar(w/(5*5*35),h);
                % view(net)
                Validation_Predict_label_c = sim(net,Validation_Test_set); % ����
                %
                GetResult(Validation_Predict_label_c,Validation_Test_set_label_c);
            end
        end
    end
end

ML.BP.CrossValidation.TrainFunction = TrainFunction;
disp('========= �����������ǽ�����֤�Ľ��������===========================================');
GetParameter(2);

toc;
close(h);

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GetResult(Validation_Predict_label_c,Validation_Test_set_label_c)
global ML

Validation_Predict_label=vec2ind(Validation_Predict_label_c);
Validation_Test_set_label=vec2ind(Validation_Test_set_label_c);
% ������
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
        disp('========= ������֤--�ָ��ߣ�������� ������===========================================');
        GetParameter(2);
    end
elseif ML.BP.CrossValidation.Result.Fscore > ML.BP.CrossValidation.Parameter.Fscore_min
    if ML.BP.CrossValidation.Result.accuracy > ML.BP.CrossValidation.Parameter.accuracy_min
        GetParameter(1);
        ML.BP.CrossValidation.Parameter.flag = {'min(F) > 0'};
        disp('========= ������֤--�ָ��ߣ���õ����������  ������===========================================');
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
        disp('��������Ϊ���к�Ϊ������ʵ�������к�Ϊ������Ԥ����');        
        disp([ML.BP.CrossValidation.Parameter.flag;...
            '��ǰ�����Ԫ����Ϊ��' num2str(ML.BP.CrossValidation.Parameter.Best_neuro_num); ...
            '  ��ʱ������ȷ��Ϊ��' num2str(ML.BP.CrossValidation.Parameter.accuracy_min);...
            '  ���ݺ���Ϊ��' ML.BP.CrossValidation.Parameter.transfer_function;...
            '  ѵ������Ϊ��' ML.BP.CrossValidation.Parameter.train_function]);
        disp(ML.BP.CrossValidation.Parameter.result);
        
end
end

