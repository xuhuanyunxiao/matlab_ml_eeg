function FeatureData = MachineLearning_CalFeatureTimeSeriesmultiChan(data)

global ML
ChannelNum = ML.Parameter.ChannelNum;

TimeSeries = cell(length(data(:,1)),ChannelNum+1);
for fileN = 1:length(data(:,1))
    for Chan = 1:ChannelNum % length(data(1,:))
        EEGdata = double(data{fileN,Chan});
        % 1 一维向量的LzC复杂度
        lzc = LzCm(EEGdata);
        TimeSeries{fileN,Chan}(1,1) = lzc;
        
        % 2 一维向量的Renyi熵
        %N--计算Renyi熵值时所取得的间隔数
        %q--计算Renyi熵值时的系数
        %q>1时，概率大的子序列在计算中占主导作用
        %q<1时，概率小的子序列在计算中占主导作用
        Nre = 100;
        qre = 1.5;
        re = Renyi(EEGdata,Nre,qre);
        TimeSeries{fileN,Chan}(1,2) = re;
        
        % 3 一维向量的Tsallis熵
        %N--计算Tsallis熵值时所取得的间隔数
        %q--计算Tsallis熵值时的系数
        %q>1时，概率大的子序列在计算中占主导作用
        %q<1时，概率小的子序列在计算中占主导作用
        Nte = 2;
        qte = 1.5;
        te = Tsallis(EEGdata,Nte,qte) ;
        TimeSeries{fileN,Chan}(1,3) = te;
        
        % 4 一维向量的小波熵
        % head : ERP开头不需要计算的一段
        % tail : ERP的总长度
        % step : 小波分解步进长度
        head = 0;
        tail = length(EEGdata);
        step = length(EEGdata);
        wentropy =Wavelet_Entropy(EEGdata,head,tail,step);
        TimeSeries{fileN,Chan}(1,4) = mean(wentropy);
        
        % 5 AR模型参数估计法：自回归模型，AR系数代表信号的特征
        pnts=length(EEGdata);  % 数据个数
        AR_jieshu_n=10; %阶数选定
        Y=EEGdata'; Y(1:AR_jieshu_n)=[];
        m=pnts-AR_jieshu_n;  X=[];   %构造系数矩阵X
        for i=1:m
            for j=1:AR_jieshu_n
                X(i,j)=EEGdata(AR_jieshu_n+i-j);
            end
        end
        fai=inv(X'*X)*(X'*Y);        
        TimeSeries{fileN,Chan}(1,5:4+AR_jieshu_n) = fai';
    end
    
    % 两个一维向量x和y的互信息 information
    if ChannelNum > 1
        eegdata = data(fileN,:);
        Nzuhe = nchoosek(ChannelNum,2); % 多通道两两组合的总数
        Czuhe = combntns(1:ChannelNum,2); % 多通道两两组合的情况
        for i = 1:Nzuhe
            x = double(eegdata{1,Czuhe(i,1)});
            y = double(eegdata{1,Czuhe(i,2)});
            estimate = information(x,y);
        end
        TimeSeries{fileN,ChannelNum+1}(1,1:Nzuhe) = estimate;
    end
end

TimeSeriesParam = {'Renyi熵' 'Nre' num2str(Nre) 'qte' num2str(qte);...
    'Tsallis熵' 'Nte' num2str(Nte) 'qte' num2str(qte);...
    '小波熵' 'head' num2str(head) 'step' num2str(step);...
    'AR参数模型' '阶数' num2str(AR_jieshu_n) '' ''};
if ChannelNum > 1
    for i = 1:Nzuhe
        eval(['Information(',num2str(i),') = ','{''','互信息',num2str(i),'''}',';']);
    end
    for i = 1:AR_jieshu_n % n 为阶数10
        eval(['AR(',num2str(i),') = ','{''','AR系数',num2str(i),'''}',';']);
    end
    TimeSeriesTitle = {'LzC复杂度','Renyi熵','Tsallis熵','小波熵',AR{:}, Information{:}};
else
    for i = 1:AR_jieshu_n % n 为阶数10
        eval(['AR(',num2str(i),') = ','{''','AR系数',num2str(i),'''}',';']);
    end
    TimeSeriesTitle = {'LzC复杂度','Renyi熵','Tsallis熵','小波熵',AR{:}};
end

FeatureData = TimeSeries;
ML.Feature.TimeSeries.TimeSeriesParam = TimeSeriesParam;
ML.Feature.TimeSeries.TimeSeriesTitle = TimeSeriesTitle;
ML.FeaturePlot.XTickLabel = TimeSeriesTitle;
ML.FeaturePlot.AR_jieshu_n = AR_jieshu_n;

end