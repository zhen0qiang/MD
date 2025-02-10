**在MD中应用了[周期边界条件](https://zhida.zhihu.com/search?content_id=266328985&content_type=Answer&match_order=1&q=周期边界条件&zhida_source=entity)（PBC）的box是会影响到最终计算结果的！所以非常重要！**

**1**.先举个最为直观的例子：

![img](https://pic1.zhimg.com/80/v2-101072bd9201a0150f1497bf85e3480e_720w.webp?source=1def8aca)

在这个图中只画出了1个x-y方向的周期重复，Lx，Ly和Lz是box的三个边长，r是跨越盒子的两个原子之间的距离，此时右边绿色原子的x坐标等于左边绿色原子的x坐标+Lx。

接着运行MD解牛顿方程，此时分子受力运动以达到结构优化态，即能量最低态。**注意这时候box就要分为2种模式了！即固定模式和运动模式，没错，盒子也需要运动**，如果在**固定模式下，盒子的边长不变，是允许分子溢出盒子的**，假如左边的红色原子跑到了右边的盒子里，那么同时就有另一个红色原子从左边进入，维持了盒子内原子的密度始终保持不变。

但计算出的能量就是最低能量吗？答案是NO，因为我们在计算r的时候，要用G2的坐标减去R1的坐标开方，而xG2=xG1+LX，**可见Lx在这里参与到了我们的MD进程中！Lx就仿佛一个无形的力硬生生把r给拉扯了一下，这就是盒子对我们结果的影响，在某些文献中，也可以把这种影响抽象等效于是施加在盒子上的压力。**

如果是在运动模式下呢？我们允许盒子自由运动，Lx，Ly和Lz的大小可变，那么最终的优化结构可能就是这样的：

![img](https://picx.zhimg.com/80/v2-57596cad638d8514981aaba39a3088b0_720w.webp?source=1def8aca)

**盒子的大小缩小了，显而易见r也变小了，最终的势能E会更低。**

**2**.进一步，不仅是盒子的边长会影响结构优化，复杂一些，盒子边长间的角度也会影响E，这种情况下盒子就不再是一个标准的长方体结构了，而是某些面变成了平行四边形，由于三维情况下过于复杂，下面举一个2D石墨烯的例子：

![img](https://pic1.zhimg.com/80/v2-e87f64b8676c4efc28547d8968ee89f9_720w.webp?source=1def8aca)

此为二维结构，不再考虑z方向，N个原子的（x，y）坐标加盒子的Lx，Ly， θ\theta\theta ，总共2N+3个自由度。

它的势能函数：

![img](https://picx.zhimg.com/80/v2-cea97bef93f7b6b889eb33beb9550da0_720w.webp?source=1def8aca)

此处方便起见简化势能函数为：

E=∑iN(ri2−d2)2E = \sum\limits_i^N {{{({r_i}^2 - {d^2})}^2}}   E = \sum\limits_i^N {{{({r_i}^2 - {d^2})}^2}}    

只有一个ri为分子间距离，d是常数，然后计算碳分子间受力：

Fi=−∇⋅E=−4(ri2−d2)r→i{F_i} =  - \nabla  \cdot E =  - 4({r_i}^2 - {d^2}){\vec r_i} {F_i} =  - \nabla  \cdot E =  - 4({r_i}^2 - {d^2}){\vec r_i}  

当我们计算盒子边界上的原子的受力的时候，有如下计算：

**因为此时的C-C键跨越的了盒子边界，要进行特别处理，以便得出x，y方向的差：**

dx=dx+Lxdx=dx−Lxdy=dy+Lydy=dy−Ly(dx<−0.5∗Lx)(dx>0.5∗Lx)(dy<−0.5∗Ly)(dy>0.5∗Ly)\begin{array}{*{20}{c}} {dx = dx + Lx}\\ {dx = dx - Lx}\\ {dy = dy + Ly}\\ {dy = dy - Ly} \end{array}\begin{array}{*{20}{c}} {(dx <  - 0.5*Lx)}\\ {(dx > 0.5*Lx)}\\ {(dy <  - 0.5*Ly)}\\ {(dy > 0.5*Ly)} \end{array} \begin{array}{*{20}{c}} {dx = dx + Lx}\\ {dx = dx - Lx}\\ {dy = dy + Ly}\\ {dy = dy - Ly} \end{array}\begin{array}{*{20}{c}} {(dx <  - 0.5*Lx)}\\ {(dx > 0.5*Lx)}\\ {(dy <  - 0.5*Ly)}\\ {(dy > 0.5*Ly)} \end{array}  

最后将处理过的dx和dy带入计算r： r=dx2+dy2{\rm{r}} = \sqrt {d{x^2} + d{y^2}}  {\rm{r}} = \sqrt {d{x^2} + d{y^2}}   

因为我们还改变了盒子的角度 θ\theta\theta ，那么 θ\theta\theta 也会参与到r的计算中：此时的dx也发生了变化：

dx=dx+y2tan⁡θ−y1tan⁡θdx = dx + \frac{{{y_2}}}{{\tan \theta }} - \frac{{{y_1}}}{{\tan \theta }} dx = dx + \frac{{{y_2}}}{{\tan \theta }} - \frac{{{y_1}}}{{\tan \theta }}  

**至此我们发现了Lx，Ly和** θ\theta\theta **都参与到了MD中，它们通过影响r而影响受力F，从而影响了最终的能量E！**

**具体如何让盒子动起来呢？我们需要将额外的三个自由度也放到我们的MD算法中，作为一个“虚拟”原子，这样盒子也可以弛豫，所得到的最终能量才是最低稳定态。**

**3.**LAMMPS中的盒子弛豫命令：

我一般都是自己写MD程序和设计算法，有很多同学会直接用LAMMPS这些[开源软件](https://zhida.zhihu.com/search?content_id=266328985&content_type=Answer&match_order=1&q=开源软件&zhida_source=entity)，我也是正在学习中，据我所知，LAMMPS中也有盒子的两种模式的切换方法，即固定模式，和盒子运动模式：

以下内容引用自LAMMPS官网：



```text
fix ID group-ID box/relax keyword value ...
ID, group-ID are documented in fix command
box/relax = style name of this fix command

EXAMPLES：
fix 1 all box/relax iso 0.0 vmax 0.001
fix 2 water box/relax aniso 0.0 dilate partial
fix 2 ice box/relax tri 0.0 couple xy nreset 100
```