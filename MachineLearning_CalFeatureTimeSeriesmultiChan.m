function FeatureData = MachineLearning_CalFeatureTimeSeriesmultiChan(data)

global ML
ChannelNum = ML.Parameter.ChannelNum;

TimeSeries = cell(length(data(:,1)),ChannelNum+1);
for fileN = 1:length(data(:,1))
    for Chan = 1:ChannelNum % length(data(1,:))
        EEGdata = double(data{fileN,Chan});
        % 1 һά������LzC���Ӷ�
        lzc = LzCm(EEGdata);
        TimeSeries{fileN,Chan}(1,1) = lzc;
        
        % 2 һά������Renyi��
        %N--����Renyi��ֵʱ��ȡ�õļ����
        %q--����Renyi��ֵʱ��ϵ��
        %q>1ʱ�����ʴ���������ڼ�����ռ��������
        %q<1ʱ������С���������ڼ�����ռ��������
        Nre = 100;
        qre = 1.5;
        re = Renyi(EEGdata,Nre,qre);
        TimeSeries{fileN,Chan}(1,2) = re;
        
        % 3 һά������Tsallis��
        %N--����Tsallis��ֵʱ��ȡ�õļ����
        %q--����Tsallis��ֵʱ��ϵ��
        %q>1ʱ�����ʴ���������ڼ�����ռ��������
        %q<1ʱ������С���������ڼ�����ռ��������
        Nte = 2;
        qte = 1.5;
        te = Tsallis(EEGdata,Nte,qte) ;
        TimeSeries{fileN,Chan}(1,3) = te;
        
        % 4 һά������С����
        % head : ERP��ͷ����Ҫ�����һ��
        % tail : ERP���ܳ���
        % step : С���ֽⲽ������
        head = 0;
        tail = length(EEGdata);
        step = length(EEGdata);
        wentropy =Wavelet_Entropy(EEGdata,head,tail,step);
        TimeSeries{fileN,Chan}(1,4) = mean(wentropy);
        
        % 5 ARģ�Ͳ������Ʒ����Իع�ģ�ͣ�ARϵ�������źŵ�����
        pnts=length(EEGdata);  % ���ݸ���
        AR_jieshu_n=10; %����ѡ��
        Y=EEGdata'; Y(1:AR_jieshu_n)=[];
        m=pnts-AR_jieshu_n;  X=[];   %����ϵ������X
        for i=1:m
            for j=1:AR_jieshu_n
                X(i,j)=EEGdata(AR_jieshu_n+i-j);
            end
        end
        fai=inv(X'*X)*(X'*Y);        
        TimeSeries{fileN,Chan}(1,5:4+AR_jieshu_n) = fai';
    end
    
    % ����һά����x��y�Ļ���Ϣ information
    if ChannelNum > 1
        eegdata = data(fileN,:);
        Nzuhe = nchoosek(ChannelNum,2); % ��ͨ��������ϵ�����
        Czuhe = combntns(1:ChannelNum,2); % ��ͨ��������ϵ����
        for i = 1:Nzuhe
            x = double(eegdata{1,Czuhe(i,1)});
            y = double(eegdata{1,Czuhe(i,2)});
            estimate = information(x,y);
        end
        TimeSeries{fileN,ChannelNum+1}(1,1:Nzuhe) = estimate;
    end
end

TimeSeriesParam = {'Renyi��' 'Nre' num2str(Nre) 'qte' num2str(qte);...
    'Tsallis��' 'Nte' num2str(Nte) 'qte' num2str(qte);...
    'С����' 'head' num2str(head) 'step' num2str(step);...
    'AR����ģ��' '����' num2str(AR_jieshu_n) '' ''};
if ChannelNum > 1
    for i = 1:Nzuhe
        eval(['Information(',num2str(i),') = ','{''','����Ϣ',num2str(i),'''}',';']);
    end
    for i = 1:AR_jieshu_n % n Ϊ����10
        eval(['AR(',num2str(i),') = ','{''','ARϵ��',num2str(i),'''}',';']);
    end
    TimeSeriesTitle = {'LzC���Ӷ�','Renyi��','Tsallis��','С����',AR{:}, Information{:}};
else
    for i = 1:AR_jieshu_n % n Ϊ����10
        eval(['AR(',num2str(i),') = ','{''','ARϵ��',num2str(i),'''}',';']);
    end
    TimeSeriesTitle = {'LzC���Ӷ�','Renyi��','Tsallis��','С����',AR{:}};
end

FeatureData = TimeSeries;
ML.Feature.TimeSeries.TimeSeriesParam = TimeSeriesParam;
ML.Feature.TimeSeries.TimeSeriesTitle = TimeSeriesTitle;
ML.FeaturePlot.XTickLabel = TimeSeriesTitle;
ML.FeaturePlot.AR_jieshu_n = AR_jieshu_n;

end