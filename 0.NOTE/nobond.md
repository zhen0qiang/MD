范德华相互作用能量描述了分子之间由于原子或基团之间的瞬时偶极相互作用而产生的排斥力。它通常由两部分组成：硬球排斥力和吸引能，可以分别用以下公式表示：

### 硬球排斥力（Lennard-Jones排斥力）

硬球排斥力通常用Lennard-Jones势能来描述，其公式如下：

\[ E_{\text{rep}} = 4 \epsilon \left( \frac{\sigma}{r} \right)^{12} \]

其中：
- \( E_{\text{rep}} \) 是排斥能量（单位：焦耳或千卡）。
- \( \epsilon \) 是势能深度（单位：焦耳或千卡），表示排斥力的强度。
- \( \sigma \) 是原子或基团的范德华半径（单位：纳米）。
- \( r \) 是原子或基团之间的距离（单位：纳米）。

### 吸引能（Lennard-Jones吸引能）

吸引能通常也用Lennard-Jones势能来描述，其公式如下：

\[ E_{\text{attr}} = 4 \epsilon \left( \frac{\sigma}{r} \right)^{6} - \epsilon \left( \frac{\sigma}{r} \right)^{12} \]

其中，公式与排斥能类似，但多了一个负的项，表示吸引能比排斥能低。

### 总范德华相互作用能量

总范德华相互作用能量是排斥能和吸引能的和：

\[ E_{\text{vdw}} = E_{\text{rep}} + E_{\text{attr}} \]

或者，使用单个Lennard-Jones势能公式：

\[ E_{\text{vdw}} = 4 \epsilon \left( \frac{\sigma}{r} \right)^{6} \left( 1 - \frac{1}{4} \left( \frac{\sigma}{r} \right)^{6} \right) \]

这个公式描述了范德华相互作用随距离变化的能量，当原子或基团之间的距离很近时，排斥力占主导地位；当距离较远时，吸引力占主导地位。