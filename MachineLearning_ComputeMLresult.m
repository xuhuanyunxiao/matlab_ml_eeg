function [result,confusion_matrix,accuracy,precision,recall,Fscore,TNR,FPR]= MachineLearning_ComputeMLresult

global ML
Name = ML.DataDescription.ConditionName ;
Predict_label = ML.Label.Predict_label ;
Test_set_label = ML.Label.Test_set_label ;

class_num=length(Name);
Labels = [Test_set_label Predict_label];

% confusion matrix ��������
% ��֮��Ϊ����ʵ��������֮��Ϊ����Ԥ����
confusion_matrix=zeros(class_num,class_num);
for i = 1:class_num
    label = Labels(Labels(:,1)==i,:);  % ����ȡ��ʵ�ʱ�ǩ�и��������
    for j = 1:class_num
        confusion_matrix(i,j) = length(find(label(:,2)==j));
    end
end

% error ������
error=length(find(Predict_label~=Test_set_label))/length(Test_set_label);

% accuracy  ��ȷ��
accuracy = 1-error;

% precision ��׼��
% recall TPR �ٻ��ʡ������ԡ�������
% F-measure F1����
precision = zeros(class_num,1);
recall = zeros(class_num,1);
Fscore = zeros(class_num,1);
correct_num = sum(diag(confusion_matrix));
class_correct_num = diag(confusion_matrix);
for p = 1:class_num
    precision(p) = class_correct_num(p)/sum(confusion_matrix(:,p)); % �����к�
    recall(p) = class_correct_num(p)/sum(confusion_matrix(p,:)); % �����к�
    recall(isnan(recall))=0;
    precision(isnan(precision))=0;
    Fscore(p) = (2*precision(p)*recall(p))/(precision(p)+recall(p));
    Fscore(isnan(Fscore))=0;
end

% TNR �����ԡ��渺��
TNR = zeros(class_num,1);
P = 1:class_num;
for p = 1:class_num
    TNR(p) = sum(class_correct_num(P~=p))/sum(sum(confusion_matrix(P~=p,:)));       
end
TNR(isnan(TNR))=0;

% FPR ������
FPR = 1- TNR;

% disp
result = cell(class_num+2,class_num+6);
result(1,:) =['��������' Name '�к�' '������' '��׼��' '�ٻ���/������' 'F1����']; 
result(2:class_num+1,:) = [Name' num2cell([confusion_matrix sum(confusion_matrix,2) TNR precision recall Fscore])];
result(class_num+2,:) = ['�к�' num2cell([sum(confusion_matrix) sum(sum(confusion_matrix))]) ...
    'Ԥ����ȷ��' num2cell(correct_num) '��ȷ��' num2cell(accuracy)];

end



