# CNN - FPGA

<!-- TOC -->

- [CNN - FPGA](#cnn---fpga)
    - [项目由来](#项目由来)
    - [使用](#使用)
        - [Conv2d](#conv2d)
        - [Max_pool](#max_pool)
        - [Avg_pool](#avg_pool)
        - [Relu_activation](#relu_activation)
        - [FullConnect](#fullconnect)
    - [使用示例](#使用示例)

<!-- /TOC -->

## 项目由来

&emsp;&emsp;毕业设计，为了蹭热点，选了几个和人工智能相关的课题，本意是希望通过毕业设计让自己了解一下机器学习，比如CNN一类的。很不幸，被体系结构实验室的老师抢走了。于是就面临了这个偏硬件的课题，用FPGA加速人工智能算法。</Br>
&emsp;&emsp;毕竟只是本科毕业设计，这个课题在我手里就变成了用FPGA加速CNN，本来的目的还是要完成，在大致了解了CNN之后，还是在极不情愿中做完了这个项目。</Br>
&emsp;&emsp;项目本质很简单，使用Verilog实现了一些CNN的模块。~~几乎没有多少实用价值。~~ 另外，和大多数FPGA加速CNN的项目一样，本项目只能运行推断，不能学习，所以没有后向传播~~这不怪我，Xilinx自己都已经放弃治疗了。~~

## 使用

&emsp;&emsp;模块设计上参照了tensorflow。因为使用了全并行的设计，所以没有引入时序，也没有做流水线~~我不信哪块FPGA板子的部件延迟会大过总线周期~~，所以在资源占用上很不合理，可能需要在规模很大的FPGA板子上才能实现一个较大的网络吧~~也就是说本项目毫无卵用~~</Br></Br>

有以下几个模块：

### Conv2d

**说明：**

&emsp;&emsp;卷积模块，可以进行二维卷积。支持多个卷积核，不同步长，是否启用边缘0填充等

**可配置参数：**

| 名称          | 说明                                | 默认值 |
| ------------- | ----------------------------------- | ------ |
| BITWIDTH      | 数据位宽                            | 8      |
| DATAWIDTH     | 图像的宽度                          | 28     |
| DATAHEIGHT    | 图像的高度                          | 28     |
| DATACHANNEL   | 图像通道数                          | 3      |
| FILTERHEIGHT  | 卷积核的高度                        | 5      |
| FILTERWIDTH   | 卷积核的宽度                        | 5      |
| FILTERBATCH   | 卷积核的数量                        | 1      |
| STRIDEHEIGHT  | 纵向步长                            | 1      |
| STRIDEWIDTH   | 横向步长                            | 1      |
| PADDINGENABLE | 边缘是否使用0填充，1代表是，0代表否 | 0      |

**输入输出：**

| 名称         | 类型   | 说明                                                                               | 长度                                                                                                                                                                                                                          |
| ------------ | ------ | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| data         | input  | 输入的图像，数据从第一个通道左上至最后一个通道右下排列，每一个像素值为有符号定点数 | BITWIDTH × DATAWIDTH × DATAHEIGHT × DATACHANNEL                                                                                                                                                                               |
| filterWeight | input  | 卷积核权值，从第一个卷积核左上开始，到最后一个卷积核右下，每一个值为有符号定点数   | BITWIDTH × FILTERHEIGHT × FILTERWIDTH × DATACHANNEL × FILTERBATCH                                                                                                                                                             |
| filterBias   | input  | 卷积核偏置，按卷积核顺序排列，每一个值为有符号定点数                               | BITWIDTH × FILTERBATCH                                                                                                                                                                                                        |
| result       | output | 输出的特征图，从第一张左上开始，到最后一张右下，每一个值为有符号定点数             | BITWIDTH × FILTERBATCH × (PADDINGENABLE == 0 ? (DATAWIDTH - FILTERWIDTH + 1) ÷ STRIDEWIDTH : (DATAWIDTH ÷ STRIDEWIDTH)) × (PADDINGENABLE == 0 ? (DATAHEIGHT - FILTERHEIGHT + 1) ÷ STRIDEHEIGHT : (DATAHEIGHT ÷ STRIDEHEIGHT)) |

### Max_pool

**说明：**

&emsp;&emsp;最大池化模块，可以对输入进行最大池化运算。

**可配置参数：**

| 名称        | 说明         | 默认值 |
| ----------- | ------------ | ------ |
| BITWIDTH    | 数据位宽     | 8      |
| DATAWIDTH   | 特征图的宽度 | 28     |
| DATAHEIGHT  | 特征图的高度 | 28     |
| DATACHANNEL | 特征图通道数 | 3      |
| KWIDTH      | 池化窗口宽度 | 2      |
| KHEIGHT     | 池化窗口高度 | 2      |

**输入输出：**

| 名称   | 类型   | 说明                                                                     | 长度                                                               |
| ------ | ------ | ------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| data   | input  | 输入的特征图，像素数据从左上至右下排列，每一个值为有符号定点数           | BITWIDTH × DATAWIDTH × DATAHEIGHT × DATACHANNEL                    |
| result | output | 输出的特征图，从第一个通道左上到最后一个通道右下，每一个值为有符号定点数 | BITWIDTH × DATAWIDTH ÷ KWIDTH × DATAHEIGHT ÷ KHEIGHT × DATACHANNEL |

### Avg_pool

**说明：**

&emsp;&emsp;平均池化模块，可以对输入进行平均池化运算。

**可配置参数：**

| 名称        | 说明         | 默认值 |
| ----------- | ------------ | ------ |
| BITWIDTH    | 数据位宽     | 8      |
| DATAWIDTH   | 特征图的宽度 | 28     |
| DATAHEIGHT  | 特征图的高度 | 28     |
| DATACHANNEL | 特征图通道数 | 3      |
| KWIDTH      | 池化窗口宽度 | 2      |
| KHEIGHT     | 池化窗口高度 | 2      |

**输入输出：**

| 名称   | 类型   | 说明                                                                             | 长度                                                               |
| ------ | ------ | -------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| data   | input  | 输入的特征图，数据从第一个通道左上至最后一个通道右下排列，每一个值为有符号定点数 | BITWIDTH × DATAWIDTH × DATAHEIGHT × DATACHANNEL                    |
| result | output | 输出的特征图，从第一个通道左上到最后一个通道右下，每一个值为有符号定点数         | BITWIDTH × DATAWIDTH ÷ KWIDTH × DATAHEIGHT ÷ KHEIGHT × DATACHANNEL |

### Relu_activation

**说明：**

&emsp;&emsp;ReLU激活函数模块。可以根据情况决定卷积之后的特征图要不要连接激活函数。

**可配置参数：**

| 名称        | 说明         | 默认值 |
| ----------- | ------------ | ------ |
| BITWIDTH    | 数据位宽     | 8      |
| DATAWIDTH   | 特征图的宽度 | 28     |
| DATAHEIGHT  | 特征图的高度 | 28     |
| DATACHANNEL | 特征图通道数 | 3      |

**输入输出：**

| 名称   | 类型   | 说明                                                                             | 长度                                            |
| ------ | ------ | -------------------------------------------------------------------------------- | ----------------------------------------------- |
| data   | input  | 输入的特征图，数据从第一个通道左上至最后一个通道右下排列，每一个值为有符号定点数 | BITWIDTH × DATAWIDTH × DATAHEIGHT × DATACHANNEL |
| result | output | 输出的特征图，从第一个通道左上到最后一个通道右下，每一个值为有符号定点数         | BITWIDTH × DATAHEIGHT × DATAWIDTH × DATACHANNEL |

### FullConnect

**说明：**

&emsp;&emsp;全连接层模块。数据会被展开为一维矩阵，进行全连接运算。

**可配置参数：**

| 名称        | 说明                   | 默认值 |
| ----------- | ---------------------- | ------ |
| BITWIDTH    | 数据位宽               | 8      |
| LENGTH      | 输入数据展开后的长度   | 25     |
| FILTERBATCH | 全连接层参数矩阵的个数 | 1      |

**输入输出：**
| 名称   | 类型   | 说明                                                                               | 长度                            |
| ------ | ------ | ---------------------------------------------------------------------------------- | ------------------------------- |
| data   | input  | 输入的特征图，数据从第一个通道左上至最后一个通道右下排列，每一个值为有符号定点数   | BITWIDTH × LENGTH               |
| weight | input  | 参数矩阵的权值，从第一个参数矩阵开头至最后一个参数矩阵结尾，每一个值为有符号定点数 | BITWIDTH × LENGTH × FILTERBATCH |
| bias   | input  | 参数矩阵的偏置，按参数矩阵顺序排列，每一个值为有符号定点数                         | BITWIDTH × FILTERBATCH          |
| result | output | 输出结果也为一维矩阵，每一个值为有符号定点数，顺序对应权值矩阵的顺序               | BITWIDTH × FILTERBATCH          |

## 使用示例

```verilog
input [4703:0] data;
output [7:0] result;

reg [1295:0] weight1;
reg [47:0] bias1;
wire [6911:0] cov_result1;
wire [1727:0] result1, result1_activation;

reg [1295:0] weight2;
reg [23:0] bias2;
wire [383:0] cov_result2;
wire [95:0] result2, result2_activation;

reg [1919:0] weight3;
reg [159:0] bias3;
wire [159:0] result3;

reg [159:0] weight4;
reg [7:0] bias4;

Conv2d#(8, 14, 14, 3, 3, 3, 6, 1, 1, 0) conv2d_1(data, weight1, bias1, cov_result1);
Max_pool#(8, 12, 12, 6, 2, 2) max_pool_1(cov_result1, result1);
Relu_activation#(8, 6, 6, 6) relu_activation_1(result1, result1_activation);

Conv2d#(8, 6, 6, 6, 3, 3, 3, 1, 1, 0) conv2d_2(result1_activation, weight2, bias2, cov_result2);
Max_pool#(8, 4, 4, 3, 2, 2) max_pool_2(cov_result2, result2);
Relu_activation#(8, 2, 2, 3) relu_activation_2(result2, result2_activation);

FullConnect#(8, 12, 20) fullConnect_1(result2_activation, weight3, bias3, result3);

FullConnect#(8, 20, 1) fullConnect_2(result3, weight4, bias4, result);
```

上面这段代码创建了一个输入为14×14，包含两个卷积层，两个全连接层的CNN。卷积核大小是3×3，卷积层采用最大池化，窗口大小为2×2，并且使用ReLU激活函数，第一个卷积层有6个卷积核，第二个卷积层有3个卷积核。