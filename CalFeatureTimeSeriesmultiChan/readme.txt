本文件夹一共有10个文件。分别是data.mat、eloc_file 、histogram2.m 、information.m 、LzCm.m 、Renyi.m 、topoplot.m 、Tsallis.m 、 Wavelet_Entropy.m 和本文件。
其中除本文件外，其他文件用途如下：
1 data.mat包含2个数据x和y，分别为2048点长度的一维向量。

2 information.m
  可计算两个一维向量x和y的互信息，程序中需要调用histogram2函数，因此本程序要和histogram2.m放在一起使用。

3 LzCm.m
  可计算一维向量的LzC复杂度。

4 Renyi.m
  可计算一维向量的Renyi熵。

5 topoplot.m
  可以画16导脑电地形图。程序中需要调用eloc_file文件，使用时应将本程序同eloc_file文件放在一起使用。eloc_file文件描述16导脑电图各导联位置，可由读者自行计算32导和64导位置。应注意该文件无后缀名。
 
6 Tsallis.m
  可计算一维向量的Tsallis熵。

7 Wavelet_Entropy.m 
  可计算一维向量的小波熵。该程序默认分解深度为7级。