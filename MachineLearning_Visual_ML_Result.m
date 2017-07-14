function MachineLearning_Visual_ML_Result(data)


% data
Predict_label = data.ML.Label.Predict_label;
Test_set_label = data.ML.Label.Test_set_label;

prec_rec(Predict_label, Test_set_label);

end