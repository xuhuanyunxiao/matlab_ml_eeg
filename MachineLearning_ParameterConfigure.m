function MachineLearning_ParameterConfigure

global ML
hicutoff = ML.Parameter.hicutoff ;
locutoff = ML.Parameter.locutoff ;
%% 2 EEGԤ����
switch ML.Parameter.RawPreprocessingWay
    case 1
        RejArti = 0; wavedenoise = 0; RejChan = 0;RemoveM = 0;Detr = 0;FIRband = 0;
        ML.Parameter.RawPreprocessingName = '��Ԥ����';
    case 2
        RejArti = 1; wavedenoise = 0; RejChan = 0; RemoveM = 1;Detr = 1;FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����ȫ������ ȥ��ֵ��ȥƯ�ơ��˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 3
        RejArti = 1; wavedenoise = 0; RejChan = 1; RemoveM = 1;Detr = 1;FIRband = 1; 
        ML.Parameter.RawPreprocessingName = ['Ԥ������������ ȥ��ֵ��ȥƯ�ơ��˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 4
        RejArti = 1; wavedenoise = 0; RejChan = 0; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����ȫ������ ֻ�˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 5
        RejArti = 1; wavedenoise = 0; RejChan = 1; RemoveM = 0;Detr = 0; FIRband = 1; 
        ML.Parameter.RawPreprocessingName = ['Ԥ������������ ֻ�˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 6
        RejArti = 1; wavedenoise = 1; RejChan = 0; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����С��ȥ�� ȫ������ ֻ�˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 7
        RejArti = 1; wavedenoise = 1; RejChan = 1; RemoveM = 0;Detr = 0; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����С��ȥ�� �������� ֻ�˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];        
    case 8
        RejArti = 1; wavedenoise = 1; RejChan = 0; RemoveM = 1;Detr = 1; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����С��ȥ�� ȫ������ ȥ��ֵ��ȥƯ�ơ��˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
    case 9
        RejArti = 1; wavedenoise = 1; RejChan = 1; RemoveM = 1;Detr = 1; FIRband = 1;
        ML.Parameter.RawPreprocessingName = ['Ԥ����С��ȥ�� �������� ȥ��ֵ��ȥƯ�ơ��˲�' ' (��ͨΪ��' num2str(locutoff) '-' num2str(hicutoff) ')'];
end

ML.RawPreprocessing.WaveDenoise = wavedenoise;
ML.RawPreprocessing.hicutoff = hicutoff;
ML.RawPreprocessing.RejectChannel = RejChan;
ML.RawPreprocessing.RejectArtifact = RejArti;
ML.RawPreprocessing.RemoveMean = RemoveM;
ML.RawPreprocessing.Detrend = Detr;
ML.RawPreprocessing.FIRband = FIRband;

%% 4 ������ϴ
switch ML.Parameter.FeaturePreprocessingWay
    case 1
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 0 ;feaTransformation = 1; % �任��[0 1]
        ML.Parameter.FeaturePreprocessingName = '�任��[0 1]';
    case 2
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 1 ;feaTransformation = 1; % ͳ����ѡ���任��[0 1]
        ML.Parameter.FeaturePreprocessingName = 'ͳ����ѡ���任��[0 1]';
    case 3
        feaIntegration = 0 ;feaClean = 1 ; feaReduction = 1 ;feaTransformation = 1; % ֱ��ȥ������Ⱥ�㡢ͳ����ѡ���任��[0 1]
        ML.Parameter.FeaturePreprocessingName = 'ֱ��ȥ������Ⱥ�㡢ͳ����ѡ���任��[0 1]';
    case 4
        feaIntegration = 0 ;feaClean = 1 ; feaReduction = 0 ;feaTransformation = 1; % ֱ��ȥ������Ⱥ�㡢�任��[0 1]
        ML.Parameter.FeaturePreprocessingName = 'ֱ��ȥ������Ⱥ�㡢�任��[0 1]';
    case 5
        feaIntegration = 0 ;feaClean = 0 ; feaReduction = 0 ;feaTransformation = 4; % С������淶��
        ML.Parameter.FeaturePreprocessingName = 'С������淶��';
end

% feaIntegration ����û���õ�
ML.FeaturePreprocessing.feaClean = feaClean;
ML.FeaturePreprocessing.feaIntegration = feaIntegration ;
ML.FeaturePreprocessing.feaReduction = feaReduction ;
ML.FeaturePreprocessing.feaTransformation = feaTransformation ;


end