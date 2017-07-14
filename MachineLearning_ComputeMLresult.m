function [result,confusion_matrix,accuracy,precision,recall,Fscore,TNR,FPR]= MachineLearning_ComputeMLresult

global ML
Name = ML.DataDescription.ConditionName ;
Predict_label = ML.Label.Predict_label ;
Test_set_label = ML.Label.Test_set_label ;

class_num=length(Name);
Labels = [Test_set_label Predict_label];

% confusion matrix 混淆矩阵
% 行之和为该类实际数，列之和为该类预测数
confusion_matrix=zeros(class_num,class_num);
for i = 1:class_num
    label = Labels(Labels(:,1)==i,:);  % 依次取出实际标签中各组的数据
    for j = 1:class_num
        confusion_matrix(i,j) = length(find(label(:,2)==j));
    end
end

% error 错误率
error=length(find(Predict_label~=Test_set_label))/length(Test_set_label);

% accuracy  正确率
accuracy = 1-error;

% precision 精准率
% recall TPR 召回率、敏感性、真正率
% F-measure F1分数
precision = zeros(class_num,1);
recall = zeros(class_num,1);
Fscore = zeros(class_num,1);
correct_num = sum(diag(confusion_matrix));
class_correct_num = diag(confusion_matrix);
for p = 1:class_num
    precision(p) = class_correct_num(p)/sum(confusion_matrix(:,p)); % 除以列和
    recall(p) = class_correct_num(p)/sum(confusion_matrix(p,:)); % 除以行和
    recall(isnan(recall))=0;
    precision(isnan(precision))=0;
    Fscore(p) = (2*precision(p)*recall(p))/(precision(p)+recall(p));
    Fscore(isnan(Fscore))=0;
end

% TNR 特异性、真负率
TNR = zeros(class_num,1);
P = 1:class_num;
for p = 1:class_num
    TNR(p) = sum(class_correct_num(P~=p))/sum(sum(confusion_matrix(P~=p,:)));       
end
TNR(isnan(TNR))=0;

% FPR 假正率
FPR = 1- TNR;

% disp
result = cell(class_num+2,class_num+6);
result(1,:) =['混淆矩阵' Name '行和' '特异性' '精准率' '召回率/敏感性' 'F1分数']; 
result(2:class_num+1,:) = [Name' num2cell([confusion_matrix sum(confusion_matrix,2) TNR precision recall Fscore])];
result(class_num+2,:) = ['列和' num2cell([sum(confusion_matrix) sum(sum(confusion_matrix))]) ...
    '预测正确和' num2cell(correct_num) '正确率' num2cell(accuracy)];

end



